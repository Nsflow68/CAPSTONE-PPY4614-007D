# Creación del entorno

python3 -m venv mi_entorno

# Activación

source mi_entorno/bin/activate

# Requerimientos
pip install -r requirements.txt

# Estructura principal
- `app/` contiene el código de la aplicación organizado en paquetes (configuración, servicios, base de datos y UI).
- Los recursos de datos viven en `data/` y las bases SQLite en `database/`.

# Inicio de sesión
- Usuario administrador por defecto: `admin`
- Contraseña: `admin123`

# Ejecutar la aplicación
python main.py
