import SwiftUI
import MapKit

struct GatheringMapScreen: View {
    @State private var gatherings: [Gathering] = []
    @State private var isLoading = false
    @State private var error: String?
    @State private var selectedGathering: Gathering?
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631),
            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        )
    )
    private let container: DependencyContainer

    init(container: DependencyContainer) {
        self.container = container
    }

    private var gatheringsWithCoordinates: [Gathering] {
        gatherings.filter { $0.latitude != nil && $0.longitude != nil }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if isLoading && gatherings.isEmpty {
                GatheringMapLoadingContent()
            } else if let errorMessage = error, gatherings.isEmpty {
                ErrorStateView(
                    message: errorMessage,
                    onRetry: { Task { await loadGatherings() } }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BelongColor.background)
            } else {
                GatheringMapContent(
                    gatherings: gatheringsWithCoordinates,
                    cameraPosition: $cameraPosition,
                    selectedGathering: $selectedGathering
                )

                // Bottom carousel
                if !gatheringsWithCoordinates.isEmpty {
                    GatheringMapCarousel(
                        gatherings: gatheringsWithCoordinates,
                        selectedGathering: $selectedGathering,
                        cameraPosition: $cameraPosition
                    )
                }
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if gatherings.isEmpty {
                await loadGatherings()
            }
        }
    }

    private func loadGatherings() async {
        isLoading = true
        error = nil
        do {
            gatherings = try await container.gatheringService.fetchFeed(city: "Melbourne", page: 1, filter: nil)
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Loading

struct GatheringMapLoadingContent: View {
    var body: some View {
        VStack(spacing: Spacing.base) {
            SkeletonView(height: 400, cornerRadius: 0)
            HStack(spacing: Spacing.md) {
                SkeletonView(width: 260, height: 140, cornerRadius: Layout.radiusMd)
                SkeletonView(width: 260, height: 140, cornerRadius: Layout.radiusMd)
            }
            .padding(.horizontal, Layout.screenPadding)
        }
    }
}

// MARK: - Map Content

struct GatheringMapContent: View {
    let gatherings: [Gathering]
    @Binding var cameraPosition: MapCameraPosition
    @Binding var selectedGathering: Gathering?

    var body: some View {
        Map(position: $cameraPosition) {
            ForEach(gatherings) { gathering in
                if let lat = gathering.latitude, let lon = gathering.longitude {
                    Annotation(gathering.title, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                        GatheringMapPin(
                            emoji: gathering.emoji,
                            isSelected: selectedGathering?.id == gathering.id
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedGathering = gathering
                            }
                        }
                    }
                }
            }
        }
        .mapStyle(.standard)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Map Pin

struct GatheringMapPin: View {
    let emoji: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 0) {
            Text(emoji)
                .font(.system(size: isSelected ? 28 : 22))
                .frame(width: isSelected ? 48 : 40, height: isSelected ? 48 : 40)
                .background(isSelected ? BelongColor.primary : BelongColor.surface)
                .clipShape(Circle())
                .shadow(
                    color: BelongShadow.level2.color,
                    radius: BelongShadow.level2.radius,
                    x: BelongShadow.level2.x,
                    y: BelongShadow.level2.y
                )
            // Pin tail
            Triangle()
                .fill(isSelected ? BelongColor.primary : BelongColor.surface)
                .frame(width: 12, height: 8)
                .offset(y: -2)
        }
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Bottom Carousel

struct GatheringMapCarousel: View {
    let gatherings: [Gathering]
    @Binding var selectedGathering: Gathering?
    @Binding var cameraPosition: MapCameraPosition

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.md) {
                ForEach(gatherings) { gathering in
                    NavigationLink(value: GatheringsRoute.detail(gathering)) {
                        GatheringMapCompactCard(
                            gathering: gathering,
                            isSelected: selectedGathering?.id == gathering.id
                        )
                    }
                    .buttonStyle(.plain)
                    .onTapGesture {
                        withAnimation {
                            selectedGathering = gathering
                            if let lat = gathering.latitude, let lon = gathering.longitude {
                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                    )
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Layout.screenPadding)
            .padding(.vertical, Spacing.md)
        }
        .background(
            LinearGradient(
                colors: [.clear, BelongColor.background.opacity(0.95), BelongColor.background],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Compact Card

struct GatheringMapCompactCard: View {
    let gathering: Gathering
    let isSelected: Bool

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: gathering.startsAt)
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            Text(gathering.emoji)
                .font(.system(size: 28))
                .frame(width: 52, height: 52)
                .background(BelongColor.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: Layout.radiusSm))

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(gathering.title)
                    .font(BelongFont.secondaryMedium())
                    .foregroundStyle(BelongColor.textPrimary)
                    .lineLimit(1)
                Text(dateText)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textSecondary)
                Text(gathering.formattedSpots)
                    .font(BelongFont.caption())
                    .foregroundStyle(BelongColor.textTertiary)
            }
        }
        .padding(Spacing.md)
        .frame(width: 260)
        .background(BelongColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: Layout.radiusMd))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.radiusMd)
                .stroke(isSelected ? BelongColor.primary : Color.clear, lineWidth: 2)
        )
        .shadow(
            color: BelongShadow.level1.color,
            radius: BelongShadow.level1.radius,
            x: BelongShadow.level1.x,
            y: BelongShadow.level1.y
        )
    }
}

#Preview {
    NavigationStack {
        GatheringMapScreen(container: DependencyContainer())
    }
}
