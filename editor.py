import sys

commits = {
    "44c3f80": "feat: inicializacion del proyecto y estructura base",
    "69148a6": "chore: configuracion para despliegue en DigitalOcean",
    "884676f": "build: generacion de la version web de produccion",
    "6bdde35": "fix: correccion en la logica de autenticacion y login",
    "5497d05": "fix: reparacion del cierre de sesion en la version web",
    "5955051": "feat: eliminacion de hashes en las rutas web",
    "5e64f6f": "feat: implementacion de escaneo de tickets mediante IA",
    "d0650a5": "feat: soporte web para el procesamiento OCR con Gemini",
    "3369a78": "fix: resolucion de caida en web al inicializar OCR",
    "0b49a8c": "refactor: arquitectura web con importaciones condicionales",
    "f335cd1": "feat: integracion de cuadro de dialogo para depuracion",
    "a63aee4": "fix: correccion de errores de compilacion web",
    "0f2b501": "fix: reparacion de la navegacion para evitar pantallazos blancos",
    "3019f90": "refactor: mejora en el manejo de excepciones del OCR en web",
    "18f51bd": "chore: actualizacion del modelo Gemini a version 1.5-flash",
    "84c6347": "style: mejoras de interfaz visual e integracion de sincronizacion de gastos",
    "d109f89": "feat: opcion para eliminar compras desde la vista de detalle",
    "d7339af": "fix: correccion de error 'No autenticado' al cargar sesion inicial",
    "095991e": "fix: prevencion de acumulacion visual de notificaciones SnackBar"
}

with open(sys.argv[1], 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    new_lines.append(line)
    if line.startswith('pick '):
        parts = line.split(' ', 2)
        if len(parts) >= 2:
            hash_prefix = parts[1][:7]
            if hash_prefix in commits:
                new_msg = commits[hash_prefix]
                new_lines.append(f'exec git commit --amend -m "{new_msg}"\n')

with open(sys.argv[1], 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
