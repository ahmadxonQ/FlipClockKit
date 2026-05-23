import SwiftUI
import Combine

// MARK: - FlipClockView (public entry point)

/// A animated flip-clock countdown that displays MM:SS.
///
/// Basic usage — just pass remaining seconds:
/// ```swift
/// FlipClockView(remainingSeconds: 300)
/// ```
///
/// Full customisation:
/// ```swift
/// FlipClockView(remainingSeconds: timeLeft)
///     .flipClockStyle(
///         FlipClockStyle(
///             fontSize:      120,
///             cardColor:     .init(topStart: .black, topEnd: .gray),
///             digitColor:    .init(top: .white, bottom: .gray),
///             showLabels:    true,
///             labelText:     ("MIN", "SEC")
///         )
///     )
/// ```
public struct FlipClockView: View {
    private let remainingSeconds: Int
    private var style: FlipClockStyle = .default

    @StateObject private var d0 = _FlipViewModel()
    @StateObject private var d1 = _FlipViewModel()
    @StateObject private var d2 = _FlipViewModel()
    @StateObject private var d3 = _FlipViewModel()

    public init(remainingSeconds: Int) {
        self.remainingSeconds = remainingSeconds
    }

    private var min0: String { String(remainingSeconds / 60 / 10) }
    private var min1: String { String((remainingSeconds / 60) % 10) }
    private var sec0: String { String((remainingSeconds % 60) / 10) }
    private var sec1: String { String(remainingSeconds % 10) }

    public var body: some View {
        HStack(alignment: .center, spacing: style.groupSpacing) {
            digitGroup(label: style.labelText.0, vm1: d0, vm2: d1)
            colonSeparator
            digitGroup(label: style.labelText.1, vm1: d2, vm2: d3)
        }
        .onAppear   { syncAll(animated: false) }
        .onChange(of: remainingSeconds) { _, _ in syncAll(animated: true) }
    }

    // MARK: Private helpers

    private func syncAll(animated: Bool) {
        if animated {
            d0.text = min0; d1.text = min1
            d2.text = sec0; d3.text = sec1
        } else {
            d0.newValue = min0; d0.oldValue = min0
            d1.newValue = min1; d1.oldValue = min1
            d2.newValue = sec0; d2.oldValue = sec0
            d3.newValue = sec1; d3.oldValue = sec1
        }
    }

    private func digitGroup(label: String, vm1: _FlipViewModel, vm2: _FlipViewModel) -> some View {
        VStack(spacing: style.labelSpacing) {
            HStack(spacing: style.digitSpacing) {
                _FlipView(viewModel: vm1, style: style)
                _FlipView(viewModel: vm2, style: style)
            }
            if style.showLabels {
                Text(label)
                    .font(.system(size: style.labelFontSize, weight: .medium))
                    .foregroundColor(style.labelColor)
                    .kerning(style.labelKerning)
            }
        }
    }

    private var colonSeparator: some View {
        VStack(spacing: style.dotSpacing) {
            colonDot
            colonDot
        }
        .offset(y: style.showLabels ? -(style.labelFontSize + style.labelSpacing) / 2 : 0)
    }

    private var colonDot: some View {
        Circle()
            .fill(style.dotColor)
            .frame(width: style.dotSize, height: style.dotSize)
    }
}

// MARK: - Modifiers

extension FlipClockView {

    /// Apply a fully custom style to the flip clock.
    public func flipClockStyle(_ style: FlipClockStyle) -> FlipClockView {
        var copy = self
        copy.style = style
        return copy
    }

    /// Scale the clock uniformly by a multiplier relative to the default size.
    ///
    /// `1.0` is the default. `0.5` is half, `2.0` is double, etc.
    /// Font size, card width, spacing, dots, and labels all scale together.
    ///
    /// ```swift
    /// FlipClockView(remainingSeconds: 300)
    ///     .flipClockScale(0.75)   // compact
    ///
    /// FlipClockView(remainingSeconds: 300)
    ///     .flipClockScale(1.5)    // large
    /// ```
    public func flipClockScale(_ scale: CGFloat) -> FlipClockView {
        var copy = self
        copy.style.fontSize      = FlipClockStyle.default.fontSize     * scale
        copy.style.cardWidth     = FlipClockStyle.default.cardWidth    * scale
        copy.style.cardRadius    = FlipClockStyle.default.cardRadius   * scale
        copy.style.cardPadding   = FlipClockStyle.default.cardPadding  * scale
        copy.style.digitSpacing  = FlipClockStyle.default.digitSpacing * scale
        copy.style.groupSpacing  = FlipClockStyle.default.groupSpacing * scale
        copy.style.dotSize       = FlipClockStyle.default.dotSize      * scale
        copy.style.dotSpacing    = FlipClockStyle.default.dotSpacing   * scale
        copy.style.labelFontSize = FlipClockStyle.default.labelFontSize * scale
        copy.style.labelSpacing  = FlipClockStyle.default.labelSpacing  * scale
        return copy
    }

    /// Set an explicit digit font size. All other dimensions scale
    /// proportionally to maintain the default aspect ratio.
    ///
    /// ```swift
    /// FlipClockView(remainingSeconds: 300)
    ///     .flipClockFontSize(80)
    /// ```
    public func flipClockFontSize(_ size: CGFloat) -> FlipClockView {
        flipClockScale(size / FlipClockStyle.default.fontSize)
    }
}

// MARK: - FlipClockStyle

/// All visual parameters for ``FlipClockView``.
public struct FlipClockStyle {

    // MARK: Card
    /// Point size of the digit glyphs.
    public var fontSize:     CGFloat
    /// Width of each digit card.
    public var cardWidth:    CGFloat
    /// Corner radius of each card.
    public var cardRadius:   CGFloat
    /// Inner padding on the non-split edges of the card.
    public var cardPadding:  CGFloat

    // MARK: Colors
    /// Card background gradient stops.
    public var cardColor:    CardColor
    /// Digit foreground gradient stops.
    public var digitColor:   DigitColor
    /// Hairline divider color.
    public var dividerColor: Color
    /// Separator dot color.
    public var dotColor:     Color

    // MARK: Typography
    /// Kerning applied to the digit glyphs.
    public var digitKerning: CGFloat
    /// Font size of the MIN / SEC labels.
    public var labelFontSize: CGFloat
    /// Letter-spacing of the labels.
    public var labelKerning:  CGFloat
    /// Color of the labels.
    public var labelColor:    Color
    /// Whether to show MIN / SEC labels below each group.
    public var showLabels:    Bool
    /// Text displayed under the minutes and seconds groups respectively.
    public var labelText:     (String, String)

    // MARK: Layout
    public var digitSpacing: CGFloat
    public var groupSpacing: CGFloat
    public var dotSpacing:   CGFloat
    public var dotSize:      CGFloat
    public var labelSpacing: CGFloat

    // MARK: Animation
    public var flipDuration: Double

    // MARK: Derived (read-only)
    /// Exactly half the font size — the clip boundary for each half-card.
    public var tileHeight: CGFloat { fontSize / 2 }
    /// Height of the hairline between top and bottom halves.
    public var dividerHeight: CGFloat { 1.5 }

    // MARK: - Default style

    public static let `default` = FlipClockStyle(
        fontSize:      140,
        cardWidth:     108,
        cardRadius:    10,
        cardPadding:   10,
        cardColor:     .default,
        digitColor:    .default,
        dividerColor:  Color(red: 0.04, green: 0.035, blue: 0.03),
        dotColor:      Color.white.opacity(0.30),
        digitKerning:  -4,
        labelFontSize: 9,
        labelKerning:  3.5,
        labelColor:    Color.white.opacity(0.22),
        showLabels:    true,
        labelText:     ("MIN", "SEC"),
        digitSpacing:  6,
        groupSpacing:  32,
        dotSpacing:    18,
        dotSize:       6,
        labelSpacing:  10,
        flipDuration:  0.18
    )

    public init(
        fontSize:      CGFloat       = 140,
        cardWidth:     CGFloat       = 108,
        cardRadius:    CGFloat       = 10,
        cardPadding:   CGFloat       = 10,
        cardColor:     CardColor     = .default,
        digitColor:    DigitColor    = .default,
        dividerColor:  Color         = Color(red: 0.04, green: 0.035, blue: 0.03),
        dotColor:      Color         = Color.white.opacity(0.30),
        digitKerning:  CGFloat       = -4,
        labelFontSize: CGFloat       = 9,
        labelKerning:  CGFloat       = 3.5,
        labelColor:    Color         = Color.white.opacity(0.22),
        showLabels:    Bool          = true,
        labelText:     (String, String) = ("MIN", "SEC"),
        digitSpacing:  CGFloat       = 6,
        groupSpacing:  CGFloat       = 32,
        dotSpacing:    CGFloat       = 18,
        dotSize:       CGFloat       = 6,
        labelSpacing:  CGFloat       = 10,
        flipDuration:  Double        = 0.18
    ) {
        self.fontSize      = fontSize
        self.cardWidth     = cardWidth
        self.cardRadius    = cardRadius
        self.cardPadding   = cardPadding
        self.cardColor     = cardColor
        self.digitColor    = digitColor
        self.dividerColor  = dividerColor
        self.dotColor      = dotColor
        self.digitKerning  = digitKerning
        self.labelFontSize = labelFontSize
        self.labelKerning  = labelKerning
        self.labelColor    = labelColor
        self.showLabels    = showLabels
        self.labelText     = labelText
        self.digitSpacing  = digitSpacing
        self.groupSpacing  = groupSpacing
        self.dotSpacing    = dotSpacing
        self.dotSize       = dotSize
        self.labelSpacing  = labelSpacing
        self.flipDuration  = flipDuration
    }
}

// MARK: - CardColor

/// Background gradient for each flip card.
public struct CardColor {
    public var topStart:    Color
    public var topEnd:      Color
    public var bottomStart: Color
    public var bottomEnd:   Color

    public init(topStart: Color, topEnd: Color, bottomStart: Color, bottomEnd: Color) {
        self.topStart    = topStart
        self.topEnd      = topEnd
        self.bottomStart = bottomStart
        self.bottomEnd   = bottomEnd
    }

    /// Warm dark charcoal — matches the default style.
    public static let `default` = CardColor(
        topStart:    Color(red: 0.14,  green: 0.13,  blue: 0.13),
        topEnd:      Color(red: 0.11,  green: 0.10,  blue: 0.10),
        bottomStart: Color(red: 0.10,  green: 0.095, blue: 0.09),
        bottomEnd:   Color(red: 0.075, green: 0.07,  blue: 0.065)
    )
}

// MARK: - DigitColor

/// Foreground gradient applied to the digit glyphs.
public struct DigitColor {
    public var stops: [Gradient.Stop]

    public init(stops: [Gradient.Stop]) {
        self.stops = stops
    }

    /// Convenience: two-stop top-to-bottom gradient.
    public init(top: Color, bottom: Color) {
        stops = [
            .init(color: top,    location: 0),
            .init(color: bottom, location: 1),
        ]
    }

    /// Warm ivory — matches the default style.
    public static let `default` = DigitColor(stops: [
        .init(color: Color(red: 1.0,  green: 0.97, blue: 0.92), location: 0.00),
        .init(color: Color(red: 0.93, green: 0.89, blue: 0.82), location: 0.28),
        .init(color: Color(red: 0.68, green: 0.63, blue: 0.56), location: 0.68),
        .init(color: Color(red: 0.40, green: 0.36, blue: 0.31), location: 1.00),
    ])
}

// MARK: - Internal view model

final class _FlipViewModel: ObservableObject {
    var text: String? {
        didSet { updateTexts(old: oldValue, new: text) }
    }

    @Published var newValue: String?
    @Published var oldValue: String?
    @Published var animateTop:    Bool = false
    @Published var animateBottom: Bool = false

    private var duration: Double = FlipClockStyle.default.flipDuration

    func configure(duration: Double) {
        self.duration = duration
    }

    func updateTexts(old: String?, new: String?) {
        guard old != new else { return }
        oldValue      = old
        animateTop    = false
        animateBottom = false

        withAnimation(.easeIn(duration: duration)) { [weak self] in
            self?.newValue   = new
            self?.animateTop = true
        }
        withAnimation(.easeOut(duration: duration).delay(duration)) { [weak self] in
            self?.animateBottom = true
        }
    }
}

// MARK: - Internal flip card

private struct _FlipView: View {
    @ObservedObject var viewModel: _FlipViewModel
    let style: FlipClockStyle

    var body: some View {
        VStack(spacing: 0) {
            // TOP
            ZStack {
                _HalfCard(text: viewModel.newValue ?? "", half: .top, style: style)
                _HalfCard(text: viewModel.oldValue ?? "", half: .top, style: style)
                    .rotation3DEffect(
                        .degrees(viewModel.animateTop ? -89.9 : 0),
                        axis: (1, 0, 0), anchor: .bottom, perspective: 0.45
                    )
            }

            // Divider
            style.dividerColor
                .frame(height: style.dividerHeight)

            // BOTTOM
            ZStack {
                _HalfCard(text: viewModel.oldValue ?? "", half: .bottom, style: style)
                _HalfCard(text: viewModel.newValue ?? "", half: .bottom, style: style)
                    .rotation3DEffect(
                        .degrees(viewModel.animateBottom ? 0 : 89.9),
                        axis: (1, 0, 0), anchor: .top, perspective: 0.45
                    )
            }
        }
        .fixedSize()
        .shadow(color: .black.opacity(0.60), radius: 20, y: 10)
        .shadow(color: .black.opacity(0.50), radius:  5, y:  3)
        .shadow(color: .black.opacity(0.25), radius:  1, y:  1)
        .overlay(
            RoundedRectangle(cornerRadius: style.cardRadius)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.09), Color.white.opacity(0.02)],
                        startPoint: .top, endPoint: .bottom
                    ),
                    lineWidth: 0.75
                )
        )
    }
}

// MARK: - Internal half-card

private struct _HalfCard: View {
    enum Half { case top, bottom }

    let text:  String
    let half:  Half
    let style: FlipClockStyle

    var body: some View {
        Text(text)
            .font(.system(size: style.fontSize, weight: .thin, design: .serif))
            .kerning(style.digitKerning)
            .foregroundStyle(digitGradient)
            .fixedSize()
            // Shift the glyph so the correct half sits in the clip window.
            // Top:    no offset — top half is naturally within tileHeight.
            // Bottom: shift up by (tileHeight - fontSize) so the bottom half
            //         slides into the clip window.
            .offset(y: half == .bottom ? style.tileHeight - style.fontSize : 0)
            .frame(width: style.cardWidth, height: style.tileHeight, alignment: .top)
            .clipped()
            .padding(outerEdges, style.cardPadding)
            .background(background)
            .cornerRadius(style.cardRadius, corners: corners)
    }

    private var outerEdges: Edge.Set {
        half == .top ? [.top, .leading, .trailing] : [.bottom, .leading, .trailing]
    }

    private var corners: _CornerSet {
        half == .top ? [.topLeft, .topRight] : [.bottomLeft, .bottomRight]
    }

    private var background: LinearGradient {
        half == .top
            ? LinearGradient(
                colors: [style.cardColor.topStart, style.cardColor.topEnd],
                startPoint: .top, endPoint: .bottom)
            : LinearGradient(
                colors: [style.cardColor.bottomStart, style.cardColor.bottomEnd],
                startPoint: .top, endPoint: .bottom)
    }

    private var digitGradient: LinearGradient {
        LinearGradient(stops: style.digitColor.stops, startPoint: .top, endPoint: .bottom)
    }
}

// MARK: - Corner radius helper (cross-platform, internal)

struct _CornerSet: OptionSet {
    let rawValue: Int
    static let topLeft     = _CornerSet(rawValue: 1 << 0)
    static let topRight    = _CornerSet(rawValue: 1 << 1)
    static let bottomLeft  = _CornerSet(rawValue: 1 << 2)
    static let bottomRight = _CornerSet(rawValue: 1 << 3)
}

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: _CornerSet) -> some View {
        clipShape(_SpecificRoundedRect(radius: radius, corners: corners))
    }
}

private struct _SpecificRoundedRect: Shape {
    var radius: CGFloat
    var corners: _CornerSet

    func path(in rect: CGRect) -> Path {
        let tl: CGFloat = corners.contains(.topLeft)     ? radius : 0
        let tr: CGFloat = corners.contains(.topRight)    ? radius : 0
        let bl: CGFloat = corners.contains(.bottomLeft)  ? radius : 0
        let br: CGFloat = corners.contains(.bottomRight) ? radius : 0

        var path = Path()
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + tr),
                          control: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - br, y: rect.maxY),
                          control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - bl),
                          control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addQuadCurve(to: CGPoint(x: rect.minX + tl, y: rect.minY),
                          control: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
