import subprocess
import os

commits_map = {
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

output = subprocess.check_output(['git', 'log', '--reverse', '--format=%H %T'], text=True)
lines = output.strip().split('\n')

parent = None
for line in lines:
    if not line.strip():
        continue
    parts = line.split(' ')
    commit_hash = parts[0]
    tree_hash = parts[1]
    
    short_hash = commit_hash[:7]
    msg = commits_map.get(short_hash, "Actualizacion")
    
    author_name = subprocess.check_output(['git', 'show', '-s', '--format=%an', commit_hash], text=True).strip()
    author_email = subprocess.check_output(['git', 'show', '-s', '--format=%ae', commit_hash], text=True).strip()
    author_date = subprocess.check_output(['git', 'show', '-s', '--format=%ad', commit_hash], text=True).strip()
    
    env = os.environ.copy()
    env['GIT_AUTHOR_NAME'] = author_name
    env['GIT_AUTHOR_EMAIL'] = author_email
    env['GIT_AUTHOR_DATE'] = author_date
    env['GIT_COMMITTER_NAME'] = author_name
    env['GIT_COMMITTER_EMAIL'] = author_email
    env['GIT_COMMITTER_DATE'] = author_date
    
    cmd = ['git', 'commit-tree', tree_hash, '-m', msg]
    if parent:
        cmd.extend(['-p', parent])
        
    new_commit = subprocess.check_output(cmd, env=env, text=True).strip()
    parent = new_commit

subprocess.check_call(['git', 'checkout', parent])
subprocess.check_call(['git', 'branch', '-f', 'main', parent])
subprocess.check_call(['git', 'checkout', 'main'])
print("History rewritten successfully!")
