extends RefCounted

## Tento subor prepisuje tools/deploy_android.ps1 pri kazdom builde.
## Zobrazuje sa vlavo hore v hre ako prvy riadok.
##
## ZAMERNE tu NIE JE class_name: globalne nazvy tried su v cache, ktoru
## headless export neobnovuje, a export by na tom padol.
const STAMP := "2026-08-13 13:01:02  42ba8a8"