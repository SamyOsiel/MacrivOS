# MacrivOS 1.0 — construcción en la nube

Este repositorio construye **MacrivOS.iso** (entorno de investigación tipo WinPE,
en español, 3,50 GB, x64) en los servidores de GitHub Actions.
En tu computadora no se instala nada: todo pasa en el navegador.

## Cómo construir el ISO (3 pasos)

1. Pestaña **Actions** → **Construir MacrivOS.iso** → botón **Run workflow** → **Run workflow**.
2. Espera 25 a 45 minutos. El trabajo muestra cada paso en vivo.
3. Al terminar, entra al trabajo y descarga el artefacto **MacrivOS-ISO**
   (contiene `MacrivOS.iso`, el informe de peso y las instrucciones para el USB).

## Qué incluye el repositorio

| Carpeta / archivo | Contenido |
|---|---|
| `.github/workflows/construir.yml` | El servidor que construye el ISO |
| `MacrivOS-Kit/` | Scripts de construcción, plantillas APA 7 y biblioteca del investigador |

## Después de descargar el ISO

Graba el ISO en un USB de 8 GB o más con **Rufus portable** (un solo ejecutable,
sin instalación): esquema **GPT**, sistema destino **UEFI (no CSM)**.
El ISO arranca en el Samsung Chromebook 3 una vez flasheado el firmware UEFI
Full ROM de MrChromebox (sección 7 de la guía en PDF).

## Notas

- En un repositorio **público** la construcción es gratuita e ilimitada.
- El artefacto se conserva **30 días**; descárgalo dentro de ese plazo.
- `MacrivOS-Kit/salida/registro.txt` guarda el registro completo de cada construcción.
