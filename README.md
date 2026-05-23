# FlipClockKit

A lightweight, elegant SwiftUI flip-clock countdown view. Drop it in, pass seconds, done.

## Requirements

| Platform | Minimum |
|----------|---------|
| iOS      | 17.0    |
| macOS    | 14.0    |
| watchOS  | 10.0    |
| visionOS | 1.0     |

## Installation

### Swift Package Manager

In Xcode: **File → Add Package Dependencies** and enter the repository URL.

Or add it manually to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ahmadxonQ/FlipClockKit.git", from: "1.0.0"),
],
targets: [
    .target(dependencies: ["FlipClockKit"]),
]
```

## Usage

### Minimal — just pass seconds

```swift
import FlipClockKit

struct ContentView: View {
    @State private var timeLeft = 300   // 5 minutes

    var body: some View {
        FlipClockView(remainingSeconds: timeLeft)
    }
}
```

Drive it with a `Timer` to make it count down:

```swift
struct TimerView: View {
    @State private var timeLeft = 300

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        FlipClockView(remainingSeconds: timeLeft)
            .onReceive(timer) { _ in
                if timeLeft > 0 { timeLeft -= 1 }
            }
    }
}
```

### Custom style

```swift
FlipClockView(remainingSeconds: timeLeft)
    .flipClockStyle(
        FlipClockStyle(
            fontSize:  120,
            cardWidth: 90,
            cardColor: CardColor(
                topStart:    .black,
                topEnd:      Color(white: 0.08),
                bottomStart: Color(white: 0.07),
                bottomEnd:   Color(white: 0.05)
            ),
            digitColor: DigitColor(top: .white, bottom: Color(white: 0.5)),
            showLabels: false
        )
    )
```

### Resize modifiers

The quickest way to change the size — no need to touch `FlipClockStyle`:

```swift
// Scale uniformly (1.0 = default, 0.5 = half, 2.0 = double)
FlipClockView(remainingSeconds: timeLeft)
    .flipClockScale(0.75)

// Or set the digit font size directly — everything else scales to match
FlipClockView(remainingSeconds: timeLeft)
    .flipClockFontSize(80)
```

Both modifiers scale font size, card width, corner radius, padding, digit spacing,
group spacing, dot size, and label size together, so the clock always looks
proportional no matter the size.

Combine with `.flipClockStyle()` for fine-grained control — apply scale first,
then override individual properties:

```swift
FlipClockView(remainingSeconds: timeLeft)
    .flipClockScale(0.6)
    .flipClockStyle(FlipClockStyle(showLabels: false))
```

### All style parameters

| Parameter      | Type            | Default        | Description                              |
|----------------|-----------------|----------------|------------------------------------------|
| `fontSize`     | `CGFloat`       | `140`          | Digit glyph point size                   |
| `cardWidth`    | `CGFloat`       | `108`          | Width of each digit card                 |
| `cardRadius`   | `CGFloat`       | `10`           | Card corner radius                       |
| `cardPadding`  | `CGFloat`       | `10`           | Padding on non-split card edges          |
| `cardColor`    | `CardColor`     | warm charcoal  | Card background gradient                 |
| `digitColor`   | `DigitColor`    | warm ivory     | Digit foreground gradient                |
| `dividerColor` | `Color`         | near-black     | Hairline between top and bottom halves   |
| `dotColor`     | `Color`         | white 30%      | Colon separator dot color                |
| `digitKerning` | `CGFloat`       | `-4`           | Kerning applied to glyphs                |
| `showLabels`   | `Bool`          | `true`         | Show MIN / SEC labels                    |
| `labelText`    | `(String, String)` | `("MIN", "SEC")` | Label text for each group            |
| `digitSpacing` | `CGFloat`       | `6`            | Gap between the two digits in a group    |
| `groupSpacing` | `CGFloat`       | `32`           | Gap between minutes and seconds groups   |
| `flipDuration` | `Double`        | `0.18`         | Duration (seconds) of each flip phase    |

## License

MIT
