# SwiftBite — Real-time food delivery tracker

A Flutter app that simulates a **two-role food delivery platform**: customers
browse restaurants, build a cart, place an order and watch it move through
`placed → preparing → out for delivery → delivered` on a live map; drivers see
available orders, accept them and advance the status.

- **Customer flow:** restaurant list → menu → cart → checkout → live tracking (map + status timeline + driver card)
- **Driver flow:** available orders → accept → active delivery → mark delivered
- **Real-time feel:** order status advances on a timer, driver marker moves toward the customer; Supabase Realtime is the production path
- **Map:** custom animated map (no API key required) — drop-in replaceable with `google_maps_flutter`

## Stack

- Flutter 3.x · Dart 3.x
- Riverpod (state management)
- GoRouter-ready architecture (currently `MaterialApp` + `IndexedStack` shells)
- Custom `CustomPainter` map with markers and route line
- Google Fonts (Inter)

## Run it

```bash
flutter pub get
flutter run            # or: flutter run -d chrome
```

No backend required — runs entirely on mock data with a simulated real-time
order lifecycle. Swap `OrderRepository` for a Supabase-backed implementation
to go live.

## Architecture

```
lib/
  core/          theme, models, custom delivery map
  data/          mock catalog + order repository (real-time simulation)
  features/
    auth/        role select + login
    customer/    home, restaurant detail, cart, tracking, my orders
    driver/      available orders, active delivery
```

## Tests

```bash
flutter test
```

(Add your own tests under `test/` — the order status machine and cart totals are
pure and easy to test.)


## Demo video

<video src="https://raw.githubusercontent.com/sanjayksanthosh/delivery_tracker/master/docs/video/delivery-brag.mp4" poster="https://raw.githubusercontent.com/sanjayksanthosh/delivery_tracker/master/docs/video/delivery-brag.jpg" controls width="100%"></video>

[Download the MP4](docs/video/delivery-brag.mp4) · [Poster](docs/video/delivery-brag.jpg)

## License

MIT — see [LICENSE](LICENSE).
