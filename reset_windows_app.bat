@echo off
REM ============================================================================
REM Script para resetear completamente la aplicación en Windows
REM ============================================================================
REM Este script:
REM - Cierra la aplicación si está corriendo
REM - Limpia SharedPreferences
REM - Limpia FlutterSecureStorage
REM - Elimina la base de datos local
REM - Elimina el directorio de datos de la aplicación
REM ============================================================================

echo ============================================================================
echo Reseteando Book Sharing App - Limpieza completa de datos locales
echo ============================================================================
echo.

REM Cerrar la aplicación si está corriendo
echo [1/3] Cerrando aplicación si está corriendo...
taskkill /F /IM book_sharing_app_apk.exe 2>nul
if %ERRORLEVEL% EQU 0 (
    echo    ✓ Aplicación cerrada
) else (
    echo    ℹ Aplicación no estaba corriendo
)
echo.

REM Ejecutar el script de reset
echo [2/3] Ejecutando script de limpieza...
flutter run -d windows --target=lib/dev/reset_app_state.dart
echo.

REM Limpiar directorio de datos manualmente (por si acaso)
echo [3/3] Limpieza adicional de directorios...
set APP_DATA_DIR=%LOCALAPPDATA%\book_sharing_app_apk
if exist "%APP_DATA_DIR%" (
    echo    Eliminando %APP_DATA_DIR%...
    rmdir /S /Q "%APP_DATA_DIR%" 2>nul
    if %ERRORLEVEL% EQU 0 (
        echo    ✓ Directorio eliminado
    ) else (
        echo    ⚠ No se pudo eliminar completamente. Puedes borrarlo manualmente.
    )
) else (
    echo    ℹ Directorio no existe
)
echo.

echo ============================================================================
echo Limpieza completada!
echo ============================================================================
echo.
echo Ahora puedes ejecutar la aplicación normalmente con:
echo    flutter run -d windows
echo.
echo O simplemente ejecutar el .exe desde:
echo    build\windows\x64\runner\Release\book_sharing_app_apk.exe
echo.
pause
