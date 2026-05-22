# Guía de Despliegue e Integración - Hogentia (Fase 3 TFG)

Este documento detalla la arquitectura de despliegue de la aplicación **Hogentia**, cubriendo la integración del Backend as a Service (BaaS) con Supabase y las estrategias para el despliegue de servicios adicionales utilizando DigitalOcean.

---

## 1. Arquitectura del Sistema

El proyecto Hogentia utiliza una arquitectura moderna orientada a servicios que permite alta escalabilidad y fácil mantenimiento:
- **Frontend (Cliente):** Aplicación desarrollada en Flutter (Dart).
- **Backend Principal (BaaS):** Supabase (PostgreSQL, Autenticación, Storage, Edge Functions).
- **Infraestructura Adicional:** DigitalOcean (App Platform o Droplets) para posibles microservicios, bases de datos externas o despliegue web de la aplicación.

---

## 2. Configuración e Integración con Supabase

Supabase actúa como el núcleo del backend, eliminando la necesidad de gestionar directamente un servidor Node.js o Python para las operaciones CRUD y autenticación.

### 2.1. Creación del Proyecto
1. Accede a [Supabase](https://supabase.com) y crea un nuevo proyecto en la organización deseada.
2. Selecciona la región más cercana a tus usuarios (ej. `eu-west-1` si es para España) para minimizar la latencia.
3. Genera una contraseña segura para la base de datos (PostgreSQL).

### 2.2. Autenticación y Tablas
1. **Autenticación:** En la sección *Authentication* -> *Providers*, habilita Email/Password.
2. **Base de Datos (SQL Editor):** Crea las tablas necesarias (`usuarios`, `estancias`, `productos`, `compras`). 
   Asegúrate de habilitar **RLS (Row Level Security)** en cada tabla para garantizar que los usuarios solo puedan leer y escribir sus propios datos:
   ```sql
   -- 1. Tabla Usuarios (vinculada a auth.users de Supabase)
   CREATE TABLE usuarios (
       id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
       email TEXT NOT NULL,
       nombre TEXT,
       avatar_url TEXT,
       created_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- 2. Tabla Estancias
   CREATE TABLE estancias (
       id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
       usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
       nombre TEXT NOT NULL,
       icono TEXT DEFAULT '🏠',
       descripcion TEXT,
       orden INT DEFAULT 0,
       created_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- 3. Tabla Productos
   CREATE TABLE productos (
       id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
       estancia_id UUID REFERENCES estancias(id) ON DELETE CASCADE,
       usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
       nombre TEXT NOT NULL,
       categoria TEXT,
       cantidad INT DEFAULT 0,
       cantidad_minima INT DEFAULT 0,
       unidad TEXT,
       precio_unitario NUMERIC(10, 2),
       ticket_url TEXT,
       notas TEXT,
       activo BOOLEAN DEFAULT TRUE,
       created_at TIMESTAMPTZ DEFAULT NOW(),
       updated_at TIMESTAMPTZ
   );

   -- 4. Tabla Compras (Tickets)
   CREATE TABLE compras (
       id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
       usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
       tienda TEXT,
       total NUMERIC(10, 2) DEFAULT 0,
       imagen_ticket_url TEXT,
       fecha TIMESTAMPTZ NOT NULL,
       created_at TIMESTAMPTZ DEFAULT NOW()
   );

   -- 5. Tabla Lineas de Compra (Items del ticket)
   CREATE TABLE lineas_compra (
       id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
       compra_id UUID REFERENCES compras(id) ON DELETE CASCADE,
       producto_id UUID REFERENCES productos(id) ON DELETE SET NULL,
       nombre_item TEXT NOT NULL,
       cantidad INT DEFAULT 1,
       precio_unitario NUMERIC(10, 2) NOT NULL,
       subtotal NUMERIC(10, 2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED
   );

   -- HABILITAR RLS (Seguridad a nivel de fila)
   ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
   ALTER TABLE estancias ENABLE ROW LEVEL SECURITY;
   ALTER TABLE productos ENABLE ROW LEVEL SECURITY;
   ALTER TABLE compras ENABLE ROW LEVEL SECURITY;
   ALTER TABLE lineas_compra ENABLE ROW LEVEL SECURITY;

   -- POLÍTICAS DE SEGURIDAD (El usuario solo ve/edita sus propios datos)
   CREATE POLICY "Usuarios ven su propio perfil" ON usuarios FOR ALL USING (auth.uid() = id);
   CREATE POLICY "Usuarios ven sus estancias" ON estancias FOR ALL USING (auth.uid() = usuario_id);
   CREATE POLICY "Usuarios ven sus productos" ON productos FOR ALL USING (auth.uid() = usuario_id);
   CREATE POLICY "Usuarios ven sus compras" ON compras FOR ALL USING (auth.uid() = usuario_id);
   
   -- Política para líneas de compra (acceso a través de la compra padre)
   CREATE POLICY "Usuarios ven sus lineas de compra" ON lineas_compra FOR ALL 
   USING (EXISTS (SELECT 1 FROM compras WHERE compras.id = lineas_compra.compra_id AND compras.usuario_id = auth.uid()));

   -- 6. TRIGGER AUTOMÁTICO (¡MUY IMPORTANTE!)
   -- Esto copia el usuario de Supabase Auth a nuestra tabla pública 'usuarios' al registrarse
   CREATE OR REPLACE FUNCTION public.handle_new_user() 
   RETURNS trigger AS $$
   BEGIN
     INSERT INTO public.usuarios (id, email, nombre)
     VALUES (new.id, new.email, new.raw_user_meta_data->>'nombre');
     RETURN new;
   END;
   $$ LANGUAGE plpgsql SECURITY DEFINER;

   CREATE TRIGGER on_auth_user_created
     AFTER INSERT ON auth.users
     FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
   ```

### 2.3. Configuración de Storage (Archivos e Imágenes)
La aplicación permite a los usuarios subir su foto de perfil y fotos de los tickets de compra. Para que esto funcione, debes crear los "Buckets" (contenedores) en Supabase:
1. Ve a la sección **Storage** (icono de carpeta).
2. Haz clic en **New Bucket**.
3. Crea un bucket llamado `avatares` y asegúrate de marcarlo como **Public** (Público).
4. Crea otro bucket llamado `tickets` y márcalo también como **Public**.
5. **¡OBLIGATORIO!** Por seguridad, Supabase bloquea las subidas de archivos por defecto. Ve al **SQL Editor** y ejecuta este código para permitir que los usuarios suban y vean imágenes:

   ```sql
   -- Permitir subir archivos (INSERT) a usuarios autenticados
   CREATE POLICY "Usuarios pueden subir avatares" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'avatares');
   CREATE POLICY "Usuarios pueden subir tickets" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'tickets');

   -- Permitir leer archivos (SELECT) a todo el mundo (ya que son buckets públicos)
   CREATE POLICY "Cualquiera puede ver avatares" ON storage.objects FOR SELECT USING (bucket_id = 'avatares');
   CREATE POLICY "Cualquiera puede ver tickets" ON storage.objects FOR SELECT USING (bucket_id = 'tickets');
   
   -- Permitir borrar archivos (DELETE) solo a los dueños
   CREATE POLICY "Usuarios borran sus avatares" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'avatares' AND owner = auth.uid());
   CREATE POLICY "Usuarios borran sus tickets" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'tickets' AND owner = auth.uid());
   ```
### 2.3. Integración en Flutter
En la aplicación Flutter, la conexión se realiza usando el SDK oficial de Supabase.
1. Se añaden las credenciales al archivo `.env` en la raíz del proyecto:
   ```env
   SUPABASE_URL=https://tu-id-proyecto.supabase.co
   SUPABASE_ANON_KEY=tu-anon-key-publica
   ```
2. Inicialización en el proyecto mediante la clase envoltorio `SupabaseConfig`:
   ```dart
   // En lib/main.dart, verificamos de forma explícita que existan las credenciales:
   try {
     final url = dotenv.env['SUPABASE_URL'] ?? '';
     final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    
     if (url.isNotEmpty && anonKey.isNotEmpty) {
       // Pasamos las credenciales explícitamente a nuestra clase de configuración
       await SupabaseConfig.inicializar(url: url, anonKey: anonKey);
     }
   } catch (e) {
     debugPrint('⚠️ Supabase no configurado: $e');
   }

   // La lógica real de inicialización reside en lib/config/supabase_config.dart:
   static Future<void> inicializar({required String url, required String anonKey}) async {
     await Supabase.initialize(
       url: url,
       anonKey: anonKey,
     );
     _inicializado = true;
   }
   ```

---

## 3. Despliegue con DigitalOcean

Aunque Supabase cubre la mayor parte de las necesidades del backend, **DigitalOcean** es la plataforma elegida para hospedar partes complementarias del ecosistema de la aplicación, como la propia web generada con Flutter o APIs especializadas (por ejemplo, si usamos un servidor Python/Node para tareas pesadas).

### Opción A: DigitalOcean App Platform (Recomendada)
App Platform es un servicio PaaS (Platform as a Service) que permite desplegar aplicaciones directamente desde GitHub sin preocuparte por la infraestructura.

1. **Despliegue de Flutter Web:**
   - Si compilas Hogentia para web (`flutter build web`), puedes empujar la carpeta `build/web` a un repositorio GitHub.
   - En DigitalOcean, ve a *Apps* -> *Create App*.
   - Conecta tu repositorio de GitHub, selecciona la rama principal y configura el tipo de componente como "Static Site".
   - App Platform servirá automáticamente la aplicación, ofreciendo SSL gratuito y CDN.

2. **Despliegue de un Backend/API Auxiliar:**
   - Si creaste una API en Python (FastAPI) o Node.js para notificaciones push o procesamiento de imágenes, puedes añadirla en la misma App.
   - Selecciona "Web Service", DigitalOcean detectará automáticamente el `Dockerfile` o los archivos `requirements.txt`/`package.json` y construirá la imagen.

### Opción B: DigitalOcean Droplets (VPS)
Un Droplet es un servidor virtual (IaaS). Requiere más configuración manual pero ofrece control total.

1. **Creación:** En el panel, selecciona *Create Droplet*, elige una imagen base como Ubuntu 22.04 LTS o un "One-Click App" de Docker.
2. **Configuración Inicial:**
   - Conéctate por SSH (`ssh root@ip-del-droplet`).
   - Actualiza los paquetes: `apt update && apt upgrade`.
   - Si es necesario, instala Nginx y configura los certificados SSL con Certbot (Let's Encrypt).
3. **Despliegue:**
   - Puedes servir los archivos estáticos de Flutter Web copiando el contenido de `build/web` en `/var/www/html/`.
   - Para APIs auxiliares, puedes correr contenedores Docker en este mismo servidor expuestos a través del proxy inverso de Nginx.

## Conclusión Fase 3

Con la integración de Supabase, la aplicación Hogentia es completamente funcional, manejando usuarios, sesiones y persistencia de datos de forma segura. DigitalOcean actúa como el habilitador de cara al público, permitiendo desplegar la versión web del frontend y ofrecer la infraestructura necesaria para cualquier microservicio satélite con alta disponibilidad.
