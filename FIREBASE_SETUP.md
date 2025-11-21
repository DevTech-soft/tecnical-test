# 🔥 Configuración de Firebase

## Paso 1: Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Nombra tu proyecto: `Daily Expenses` (o el nombre que prefieras)
4. Acepta los términos y continúa
5. (Opcional) Habilita Google Analytics
6. Espera a que se cree el proyecto

## Paso 2: Configurar Android

### 2.1 Registrar la app Android

1. En la consola de Firebase, haz clic en el ícono de Android
2. Ingresa el nombre del paquete: `com.dailyexpenses.app` (o el que uses)
   - **IMPORTANTE**: Debe coincidir con el `applicationId` en `android/app/build.gradle.kts`
3. (Opcional) Dale un nombre a la app
4. (Opcional) Agrega el SHA-1 para Google Sign-In:
   - En terminal, ejecuta: `cd android && ./gradlew signingReport`
   - Copia el SHA-1 del certificado de debug

### 2.2 Descargar google-services.json

1. Descarga el archivo `google-services.json`
2. **IMPORTANTE**: Colócalo en `android/app/` (NO en `android/`)
3. Verifica que la ruta sea: `android/app/google-services.json`

### 2.3 Configurar build.gradle

Ya están configurados en el proyecto, pero verifica:

**android/build.gradle**:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle.kts** (al final del archivo):
```kotlin
apply(plugin = "com.google.gms.google-services")
```

## Paso 3: Habilitar Métodos de Autenticación

1. En Firebase Console, ve a **Authentication** > **Sign-in method**
2. Habilita:
   - **Email/Password**: Actívalo
   - **Google**: Actívalo y configura el email de soporte

## Paso 4: Configurar Firestore

1. En Firebase Console, ve a **Firestore Database**
2. Haz clic en **Create database**
3. Selecciona:
   - **Start in production mode** (más seguro, configuraremos reglas después)
   - Ubicación: **us-central** (o la más cercana a ti)
4. Haz clic en **Enable**

### 4.1 Reglas de Seguridad (Después de crear)

Ir a **Firestore Database** > **Rules** y pegar:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Permitir lectura/escritura solo a usuarios autenticados
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /expenses/{expenseId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /budgets/{budgetId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Paso 5: Verificar Instalación

Ejecuta:
```bash
flutter run
```

Si no hay errores de Firebase, ¡la configuración está completa! 🎉

## Notas Importantes

- **NO** subas `google-services.json` a Git público
- Ya está agregado a `.gitignore`
- Para producción, necesitarás un SHA-1 de tu certificado de release
- Para iOS, necesitarás hacer configuración adicional

## Solución de Problemas

### Error: "google-services.json missing"
- Verifica que el archivo esté en `android/app/`
- No debe estar en `android/` o en la raíz

### Error: "SHA-1 fingerprint"
- Para debug: Ejecuta `cd android && ./gradlew signingReport`
- Copia el SHA-1 y agrégalo en Firebase Console > Project Settings > SHA certificate fingerprints

### Error al compilar
- Limpia el proyecto: `flutter clean && flutter pub get`
- Rebuild: `cd android && ./gradlew clean`
