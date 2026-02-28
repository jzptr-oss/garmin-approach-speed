# 🚴 Approach Speed - Garmin Bike Radar Data Field

[![Build](https://github.com/YOUR_USERNAME/garmin-approach-speed/actions/workflows/build.yml/badge.svg)](https://github.com/YOUR_USERNAME/garmin-approach-speed/actions/workflows/build.yml)

Data field dla Garmin Edge pokazujący **różnicę prędkości** między Tobą a zbliżającymi się pojazdami z radaru Varia.

## 📱 Funkcje

- **Delta Speed** — pokazuje o ile km/h pojazd jedzie szybciej od Ciebie
- **Kolory ostrzegawcze:**
  - 🟢 Zielony: < 20 km/h różnicy
  - 🟡 Żółty: 20-40 km/h różnicy (+ beep)
  - 🔴 Czerwony: > 40 km/h różnicy (+ podwójny beep + wibracja)
- **CLEAR** — gdy brak pojazdów za Tobą
- **Licznik pojazdów** w rogu ekranu
- **Konfigurowalne progi** przez Garmin Connect

## 🖥️ Jak to wygląda

```
┌─────────────────┐
│      +47        │  ← Pojazd jedzie 47 km/h szybciej niż Ty
│     km/h ↓      │
│            3×   │  ← 3 pojazdy za Tobą
└─────────────────┘
```

## 📲 Instalacja

### Opcja 1: Pobierz gotową aplikację
1. Przejdź do [Releases](https://github.com/YOUR_USERNAME/garmin-approach-speed/releases)
2. Pobierz `ApproachSpeed-edge1040.prg` (lub dla Twojego urządzenia)
3. Podłącz Edge przez USB
4. Skopiuj plik do `GARMIN/APPS/`
5. Odłącz i gotowe!

### Opcja 2: Zbuduj sam (automatycznie przez GitHub Actions)
1. Fork tego repo
2. Każdy push automatycznie buduje aplikację
3. Pobierz z zakładki Actions → Artifacts

## ⚙️ Ustawienia

W aplikacji Garmin Connect → Urządzenia → Edge → Connect IQ → Approach Speed:

| Ustawienie | Domyślna | Opis |
|------------|----------|------|
| Yellow Alert | 20 km/h | Próg żółtego alarmu |
| Red Alert | 40 km/h | Próg czerwonego alarmu |
| Sound Alerts | On | Włącz/wyłącz dźwięki |

## 🔧 Dodawanie do ekranu jazdy

1. Na Edge: **Menu → Profil aktywności → Ekrany danych**
2. Wybierz ekran i pole do edycji
3. Przewiń do **Connect IQ** → **Approach Speed**
4. Gotowe!

## 🚴 Wymagania

- Garmin Edge z Connect IQ 3.2+ (530, 540, 830, 840, 1030, 1040, 1050)
- Garmin Varia Radar (RTL510/515/516 lub RVR315)
- Sparowane przez ANT+

## 🛠️ Development

### Struktura projektu
```
garmin-approach-speed/
├── .github/workflows/    # GitHub Actions (auto-build)
├── manifest.xml          # Konfiguracja aplikacji
├── monkey.jungle         # Build config
├── source/
│   ├── ApproachSpeedApp.mc    # Entry point
│   └── ApproachSpeedView.mc   # Logika + UI
└── resources/
    ├── drawables/        # Ikony
    ├── settings/         # Ustawienia
    ├── strings/          # Teksty
    └── properties.xml    # Domyślne wartości
```

### Lokalna kompilacja
```bash
# Wymagany Connect IQ SDK
monkeyc -d edge1040 -f monkey.jungle -o ApproachSpeed.prg -y developer_key.der
```

## 📝 Changelog

### v1.0.0
- Initial release
- Delta speed display
- Warning colors (green/yellow/red)
- Sound alerts (single/double beep)
- Vibration on red alert
- Configurable thresholds

## 📄 License

MIT License - używaj, modyfikuj, dziel się!

---

Made with 🚴 by Jacek & Mietek
