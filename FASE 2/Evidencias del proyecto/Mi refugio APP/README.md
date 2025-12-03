# Mi Refugio App 🛡️

**Bienestar Emocional en tu Bolsillo**

"Mi Refugio" es una aplicación móvil diseñada para apoyar el bienestar emocional de los usuarios, proporcionando herramientas de registro diario, seguimiento de hábitos saludables (hidratación, nutrición, mindfulness) y un asistente virtual (Refu) basado en IA para contención emocional.

---

## 🏗️ Arquitectura General

El sistema se compone de tres pilares principales:

1.  **Frontend Móvil (Flutter)**: Aplicación multiplataforma (Android/iOS) con diseño Material 3.
2.  **Backend (NestJS)**: API RESTful que gestiona usuarios, autenticación y persistencia de datos.
3.  **IA / LLM (Ollama)**: Módulo de inteligencia artificial local para el chatbot "Refu".

---

## 🚀 Requisitos Mínimos (Windows)

- **OS**: Windows 10/11 (64-bit).
- **RAM**: 8GB (16GB recomendado para emuladores).
- **Espacio**: 10GB libres.
- **Herramientas**: Git, Flutter SDK, Android Studio, Node.js.

---

## ⚡ Instalación Rápida

Para una guía detallada paso a paso, consulta [INSTALL_WINDOWS.md](./INSTALL_WINDOWS.md).

1.  **Clonar Repositorio**:
    ```powershell
    git clone https://github.com/Nsflow68/CAPSTONE-PPY4614-007D.git
    cd "CAPSTONE-PPY4614-007D/FASE 2/Evidencias del proyecto/Mi refugio APP"
    ```

2.  **Backend**:
    ```powershell
    cd backend_real
    npm install
    # Configurar .env (ver INSTALL_WINDOWS.md)
    npm run start:dev
    ```

3.  **Frontend**:
    ```powershell
    cd ../flutter
    flutter pub get
    flutter run
    ```

---

## 📚 Documentación Adicional

- [Guía de Instalación en Windows](./INSTALL_WINDOWS.md)
- [Guía de Contribución](./CONTRIBUTING.md)
- [Arquitectura Técnica](./docs/ARQUITECTURA.md)
