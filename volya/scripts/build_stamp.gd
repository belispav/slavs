extends RefCounted

## Tento subor prepisuje tools/deploy_android.ps1 pri kazdom builde.
## Zobrazuje sa vlavo hore v hre ako prvy riadok.
##
## ZAMERNE tu NIE JE class_name: globalne nazvy tried su v cache, ktoru
## headless export neobnovuje, a export by na tom padol.
const STAMP := "2026-09-15 14:39:10  8c2bc3e"