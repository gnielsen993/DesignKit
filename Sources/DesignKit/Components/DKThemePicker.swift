import SwiftUI

/// Full theme picker with lifestyle-feel chips.
/// Segmented `Presets | Custom`. Presets tab = category-grouped chip grid
/// where each chip previews in its preset's own palette (bg + surface card +
/// accent dot + text color). Custom tab = 4 color wells (Primary /
/// Background / Surface / Text) with per-row reset. Saved custom themes
/// appear as a "My Themes" section at the top of the grid.
public struct DKThemePicker: View {
    @ObservedObject private var themeManager: ThemeManager
    private let theme: Theme
    private let scheme: ColorScheme
    private let catalog: [PresetTheme]
    private let maxGridHeight: CGFloat?
    private let grouped: Bool

    @State private var tab: Tab = .presets
    @State private var savePromptShown = false
    @State private var saveNameDraft = ""
    @State private var renameTarget: CustomTheme? = nil
    @State private var renameDraft = ""

    private enum Tab: Hashable { case presets, custom }

    public init(
        themeManager: ThemeManager,
        theme: Theme,
        scheme: ColorScheme,
        catalog: [PresetTheme] = PresetCatalog.all,
        maxGridHeight: CGFloat? = 260,
        grouped: Bool = true
    ) {
        self.themeManager = themeManager
        self.theme = theme
        self.scheme = scheme
        self.catalog = catalog
        self.maxGridHeight = maxGridHeight
        self.grouped = grouped
        _tab = State(initialValue: themeManager.hasCustomOverrides ? .custom : .presets)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.m) {
            Picker("Mode", selection: $tab) {
                Text("Presets").tag(Tab.presets)
                Text("Custom").tag(Tab.custom)
            }
            .pickerStyle(.segmented)

            switch tab {
            case .presets: presetsGrid
            case .custom: customPanel
            }
        }
        .alert("Save this theme", isPresented: $savePromptShown) {
            TextField("Theme name", text: $saveNameDraft)
            Button("Save") {
                themeManager.saveCurrentAsCustom(name: saveNameDraft)
                saveNameDraft = ""
            }
            .disabled(saveNameDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {
                saveNameDraft = ""
            }
        } message: {
            Text("Give your custom theme a name so you can come back to it.")
        }
        .alert("Rename theme", isPresented: Binding(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )) {
            TextField("Theme name", text: $renameDraft)
            Button("Save") {
                if let target = renameTarget {
                    themeManager.renameCustomTheme(id: target.id, to: renameDraft)
                }
                renameTarget = nil
                renameDraft = ""
            }
            .disabled(renameDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Button("Cancel", role: .cancel) {
                renameTarget = nil
                renameDraft = ""
            }
        }
    }

    // MARK: - Presets

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: theme.spacing.s),
            GridItem(.flexible(), spacing: theme.spacing.s)
        ]
    }

    /// `maxGridHeight == nil` means **the host is scrolling**, so the picker
    /// must not add a scroll view of its own.
    ///
    /// It used to wrap unconditionally, so passing nil produced an unbounded
    /// `ScrollView` nested inside the host's on the same axis. It never scrolled
    /// independently — it had no height to scroll within — but it still competed
    /// for the gesture, which is what made the full theme explorer feel long and
    /// draggy on a screen that was already scrolling.
    @ViewBuilder
    private var presetsGrid: some View {
        if let maxGridHeight {
            ScrollView { gridContent }
                .frame(maxHeight: maxGridHeight)
        } else {
            gridContent
        }
    }

    @ViewBuilder
    private var gridContent: some View {
        if grouped {
            LazyVStack(alignment: .leading, spacing: theme.spacing.m) {
                if !themeManager.customThemes.isEmpty {
                    sectionHeader(.mine)
                    LazyVGrid(columns: gridColumns, spacing: theme.spacing.s) {
                        ForEach(themeManager.customThemes) { custom in
                            customChip(custom)
                        }
                    }
                }
                ForEach(catalog.groupedByCategory(), id: \.0) { category, list in
                    sectionHeader(category)
                    LazyVGrid(columns: gridColumns, spacing: theme.spacing.s) {
                        ForEach(list) { preset in
                            presetChip(preset)
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        } else {
            LazyVGrid(columns: gridColumns, spacing: theme.spacing.s) {
                ForEach(catalog) { preset in
                    presetChip(preset)
                }
            }
            .padding(.vertical, 2)
        }
    }

    /// Chip for a saved custom theme — same visual as a preset chip, with a
    /// long-press context menu for Rename/Delete.
    private func customChip(_ custom: CustomTheme) -> some View {
        let preset = custom.asPresetTheme()
        let previewScheme = preset.previewScheme(fallback: scheme)
        let a = preset.anchors(for: previewScheme)
        let isSelected = themeManager.activeCustomThemeID == custom.id

        return Button {
            themeManager.applyCustomTheme(custom)
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: theme.radii.chip, style: .continuous)
                    .fill(a.background)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(a.surface)
                    .frame(width: 30, height: 12)
                    .padding(.top, 9)
                    .padding(.leading, 10)
                // Star marker (top-right) so customs look distinct
                Image(systemName: "star.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(a.accent)
                    .padding(.top, 9)
                    .padding(.trailing, 10)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                HStack(spacing: 6) {
                    Text(preset.displayName)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(a.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 4)
                    Circle()
                        .fill(a.accent)
                        .frame(width: 10, height: 10)
                }
                .padding(.horizontal, 10)
                .padding(.top, 30)
            }
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.chip, style: .continuous)
                    .strokeBorder(
                        isSelected ? theme.colors.accentPrimary : theme.colors.border.opacity(0.6),
                        lineWidth: isSelected ? 2.5 : 0.5
                    )
            )
            .shadow(
                color: isSelected ? theme.colors.accentPrimary.opacity(0.2) : .black.opacity(0.03),
                radius: isSelected ? 6 : 2,
                x: 0,
                y: 1
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                renameDraft = custom.name
                renameTarget = custom
            } label: {
                Label("Rename", systemImage: "pencil")
            }
            Button(role: .destructive) {
                themeManager.deleteCustomTheme(id: custom.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityLabel("\(custom.name), saved theme\(isSelected ? ", selected" : "")")
    }

    private func sectionHeader(_ category: PresetCategory) -> some View {
        Text(category.displayName.uppercased())
            .font(theme.typography.caption.weight(.bold))
            .tracking(0.8)
            .foregroundStyle(theme.colors.textTertiary)
            .padding(.top, 2)
    }

    /// Lifestyle chip: entire chip background = preset's background. A tiny
    /// "surface card" rectangle + accent dot + preset name render on top,
    /// all using the preset's own tokens so the chip reads like a mini
    /// app-icon preview, not a config row.
    private func presetChip(_ preset: PresetTheme) -> some View {
        let previewScheme = preset.previewScheme(fallback: scheme)
        let a = preset.anchors(for: previewScheme)
        let isSelected = themeManager.preset.rawValue == preset.id && !themeManager.hasCustomOverrides

        return Button {
            selectPreset(preset)
        } label: {
            ZStack(alignment: .topLeading) {
                // Background
                RoundedRectangle(cornerRadius: theme.radii.chip, style: .continuous)
                    .fill(a.background)

                // Mini surface "card" preview
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(a.surface)
                    .frame(width: 30, height: 12)
                    .padding(.top, 9)
                    .padding(.leading, 10)

                // Name + accent dot
                HStack(spacing: 6) {
                    Text(preset.displayName)
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(a.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Spacer(minLength: 4)
                    Circle()
                        .fill(a.accent)
                        .frame(width: 10, height: 10)
                }
                .padding(.horizontal, 10)
                .padding(.top, 30)
            }
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.chip, style: .continuous)
                    .strokeBorder(
                        isSelected ? theme.colors.accentPrimary : theme.colors.border.opacity(0.6),
                        lineWidth: isSelected ? 2.5 : 0.5
                    )
            )
            .shadow(
                color: isSelected ? theme.colors.accentPrimary.opacity(0.2) : .black.opacity(0.03),
                radius: isSelected ? 6 : 2,
                x: 0,
                y: 1
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(preset.displayName)\(isSelected ? ", selected" : "")")
    }

    /// Selecting a preset changes the preset. It does **not** touch the display
    /// mode.
    ///
    /// It used to: 25 of the 34 shipped presets carry a `preferredScheme`, and
    /// choosing any of them silently rewrote `themeManager.mode` — a control
    /// reassigning a different control's saved value, with no warning before the
    /// tap and no notice after it. Pick Bubblegum in dark mode and you were put
    /// into light.
    ///
    /// It bought nothing. `PresetTheme.light` and `.dark` are both
    /// non-optional, so every preset has always been fully defined in both
    /// schemes. `preferredScheme` is a recommendation, and it is now expressed
    /// as one: the chip previews itself in the scheme it was designed for
    /// (`previewScheme(fallback:)`) while the app stays where the user put it.
    private func selectPreset(_ preset: PresetTheme) {
        if let raw = ThemePreset(rawValue: preset.id) {
            themeManager.preset = raw
        }
        themeManager.resetOverrides()
    }

    // MARK: - Custom panel

    private var customPanel: some View {
        let base = PresetCatalog.theme(for: themeManager.preset).anchors(for: scheme)
        let overrideColors = themeManager.overrides?.colors

        let primary = Binding<Color>(
            get: { overrideColors?.accentPrimary ?? base.accent },
            set: { themeManager.setOverrideAnchor(accent: $0) }
        )
        let background = Binding<Color>(
            get: { overrideColors?.background ?? base.background },
            set: { themeManager.setOverrideAnchor(background: $0) }
        )
        let surface = Binding<Color>(
            get: { overrideColors?.surface ?? base.surface },
            set: { themeManager.setOverrideAnchor(surface: $0) }
        )
        let text = Binding<Color>(
            get: { overrideColors?.textPrimary ?? base.textPrimary },
            set: { themeManager.setOverrideAnchor(textPrimary: $0) }
        )

        return VStack(spacing: theme.spacing.s) {
            colorRow("Primary", binding: primary, isOverridden: overrideColors?.accentPrimary != nil) {
                themeManager.setOverrideAnchor(clearAccent: true)
            }
            colorRow("Background", binding: background, isOverridden: overrideColors?.background != nil) {
                themeManager.setOverrideAnchor(clearBackground: true)
            }
            colorRow("Surface", binding: surface, isOverridden: overrideColors?.surface != nil) {
                themeManager.setOverrideAnchor(clearSurface: true)
            }
            colorRow("Text", binding: text, isOverridden: overrideColors?.textPrimary != nil) {
                themeManager.setOverrideAnchor(clearTextPrimary: true)
            }

            if themeManager.hasCustomOverrides {
                HStack(spacing: theme.spacing.s) {
                    Button {
                        saveNameDraft = ""
                        savePromptShown = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Save as theme")
                                .font(theme.typography.caption.weight(.semibold))
                        }
                        .foregroundStyle(theme.colors.accentPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radii.button, style: .continuous)
                                .fill(theme.colors.highlight)
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        themeManager.resetOverrides()
                    } label: {
                        Text("Reset")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radii.button, style: .continuous)
                                    .strokeBorder(theme.colors.border, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }
        }
    }

    private func colorRow(
        _ label: String,
        binding: Binding<Color>,
        isOverridden: Bool,
        reset: @escaping () -> Void
    ) -> some View {
        HStack(spacing: theme.spacing.s) {
            ColorPicker(selection: binding, supportsOpacity: false) {
                Text(label)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            if isOverridden {
                Button(action: reset) {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(theme.colors.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Reset \(label)")
            }
        }
        .padding(.vertical, 2)
    }
}
