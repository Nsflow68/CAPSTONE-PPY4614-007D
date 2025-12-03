# Mi Refugio App

**Bienestar Emocional en tu Bolsillo**

"Mi Refugio" es una aplicacion movil diseñada para apoyar el bienestar emocional de los usuarios, proporcionando herramientas de registro diario, seguimiento de habitos saludables (hidratacion, nutricion, mindfulness) y un asistente virtual (Refu) basado en IA para contencion emocional.

---

## Arquitectura General

El sistema se compone de tres pilares principales:

1.  **Frontend Movil (Flutter)**: Aplicacion multiplataforma (Android/iOS) con diseño Material 3.
2.  **Backend (NestJS)**: API RESTful que gestiona usuarios, autenticacion y persistencia de datos.
3.  **IA / LLM (Ollama)**: Modulo de inteligencia artificial local para el chatbot "Refu".

---

## Requisitos Minimos (Windows)

- **OS**: Windows 10/11 (64-bit).
- **RAM**: 8GB (16GB recomendado para emuladores).
- **Espacio**: 10GB libres.
- **Herramientas**: Git, Flutter SDK, Android Studio, Node.js.

---

## Instalacion Rapida

Para una guia detallada paso a paso, consulta [INSTALL_WINDOWS.md](./INSTALL_WINDOWS.md).

1.  **Clonar Repositorio**:
    ```powershell
    git clone https://github.com/Nsflow68/CAPSTONE-PPY4614-007D.git
    cd "CAPSTONE-PPY4614-007D/FASE 2/Evidencias del proyecto/Mi refugio APP"
    ```

2.  **Backend**:
    ```powershell
    cd flutter/backend/nest
    npm install
    # Configurar .env (ver INSTALL_WINDOWS.md)
    npm run start:dev
    ```

3.  **Frontend**:
    ```powershell
    cd ../..
    cd flutter
    flutter pub get
    flutter run
    ```

---

## Documentacion Adicional

- [Guia de Instalacion en Windows](./INSTALL_WINDOWS.md)
- [Guia de Contribucion](./CONTRIBUTING.md)
- [Arquitectura Tecnica](./docs/ARQUITECTURA.md)
