# 🏠 Hogentia - Tu hogar, bajo control

![Hogentia Banner](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white) ![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

Hogentia es una aplicación multiplataforma (Android, iOS y Web) diseñada para gestionar eficientemente las estancias, el inventario de productos y los gastos del hogar. Desarrollada como Trabajo de Fin de Grado (TFG), implementa una arquitectura moderna, diseño premium, y persistencia en tiempo real en la nube.

---

## ✨ Características Principales

*   **🏢 Gestión de Estancias:** Crea, edita y organiza las habitaciones de tu casa (ej. Cocina, Baño, Garaje) con iconos personalizados.
*   **📦 Inventario Inteligente (Productos):** Registra los objetos que hay en cada estancia. Configura cantidades mínimas, precios unitarios, y vincula imágenes de tickets o facturas almacenadas en la nube.
*   **🛒 Control de Compras:** Guarda el historial de tickets de compra de diferentes supermercados, con cálculo automático del subtotal por producto y almacenamiento fotográfico del recibo.
*   **📊 Análisis de Gastos:** Gráficos estadísticos que analizan el gasto mensual por categoría de producto, identificando dónde puedes ahorrar.
*   **🔒 Autenticación y Seguridad:** Integración nativa con Supabase Auth. Los datos están protegidos bajo políticas estrictas de base de datos (RLS), garantizando que solo tú accedes a tu hogar.
*   **👁️ Modo Invitado:** Permite a usuarios nuevos explorar la interfaz y funcionalidades con datos precargados (Mock) sin necesidad de registrarse.

---

## 🏗️ Arquitectura y Tecnologías

El proyecto sigue los principios de **Clean Architecture**, asegurando que el código sea testeable, escalable y mantenible.

*   **Frontend:** Flutter & Dart.
*   **Gestión de Estado:** Patrón Facade combinado con el gestor de estados `Provider`.
*   **Enrutamiento:** `GoRouter` para navegación declarativa con soporte nativo de deeplinks y redirección basada en la autenticación.
*   **Backend (BaaS):** Supabase (PostgreSQL para datos relacionales, Storage para tickets/avatares, y Authentication para la gestión de usuarios).

### Estructura de Directorios

```text
lib/
 ├── config/       # Rutas (GoRouter), inicialización de Supabase
 ├── core/         # Utilidades globales (theme, widgets reutilizables, validadores)
 └── features/     # Módulos de negocio (Clean Architecture)
      ├── auth/         # Autenticación y perfiles
      ├── estancias/    # Gestión de habitaciones
      ├── productos/    # Inventario y objetos
      ├── compras/      # Tickets y gastos
      └── gastos/       # Lógica de analíticas y gráficos
```
*Cada feature (funcionalidad) se subdivide en: `screens` (UI), `facades` (Estado), `services` (Lógica de negocio), y `repositories` (Persistencia BD).*

---

## 🚀 Configuración y Despliegue Local

### 1. Requisitos Previos
- **Flutter SDK** (versión recomendada: >= 3.22)
- Entorno de desarrollo como **VS Code** o **Android Studio**.
- Cuenta gratuita en [Supabase](https://supabase.com/).

### 2. Configurar Supabase
1. Crea un nuevo proyecto en Supabase y obtén tu `URL` y `Anon Key`.
2. En la sección "SQL Editor", ejecuta el código disponible en la documentación del proyecto (`guia_despliegue_tfg.md`) para inicializar las tablas y políticas RLS.
3. En la sección "Storage", crea dos buckets públicos: `avatares` y `tickets`.

### 3. Ejecutar la App
1. Clona este repositorio: `git clone <repo-url>`
2. Crea un archivo `.env` en la raíz del proyecto y añade tus credenciales:
   ```env
   SUPABASE_URL=tu-url-de-supabase
   SUPABASE_ANON_KEY=tu-anon-key
   ```
3. Instala las dependencias: `flutter pub get`
4. Ejecuta el proyecto: `flutter run`

---

## 📄 Licencia

Este proyecto ha sido desarrollado con fines académicos. El uso y distribución están sujetos a las políticas de la institución académica correspondiente.
