//
//  AnalyticsViewController.swift
//  DataAnalytics
//
//  Created by Karim Alweheshy on 31.07.25.
//

import UIKit
import Combine
import Inject

public class AnalyticsViewController: UIViewController, ObservableObject {
    private let dataManager = ChartDataManager()
    
    private var collectionView: UICollectionView!
    private var refreshButton: UIButton!
    private var cancellables = Set<AnyCancellable>()

    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "User Profile"
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Collection view sections
    private enum Section: Int, CaseIterable {
        case stats
        case chart
        case processingInfo
        case actions
        
        var title: String {
            switch self {
            case .stats: return "Data Statistics"
            case .chart: return "Data Visualization"
            case .processingInfo: return "Processing Details"
            case .actions: return ""
            }
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadInitialData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Analytics"
        
        setupCollectionView()
        setupRefreshButton()
    }
    
    private func setupCollectionView() {
        let layout = createLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        // Register cells and headers
        collectionView.register(StatisticCell.self, forCellWithReuseIdentifier: "StatisticCell")
        collectionView.register(ChartCell.self, forCellWithReuseIdentifier: "ChartCell")
        collectionView.register(ProcessingInfoCell.self, forCellWithReuseIdentifier: "ProcessingInfoCell")
        collectionView.register(ActionCell.self, forCellWithReuseIdentifier: "ActionCell")
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupRefreshButton() {
        refreshButton = UIButton(type: .system)
        refreshButton.setTitle("Refresh Data", for: .normal)
        refreshButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        refreshButton.setTitleColor(.white, for: .normal)
        refreshButton.backgroundColor = .systemBlue
        refreshButton.layer.cornerRadius = 12
        refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            guard let sectionType = Section(rawValue: sectionIndex) else { return nil }
            
            switch sectionType {
            case .stats:
                return self.createStatsSection()
            case .chart:
                return self.createChartSection()
            case .processingInfo:
                return self.createProcessingInfoSection()
            case .actions:
                return self.createActionsSection()
            }
        }
        return layout
    }
    
    private func createStatsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createChartSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(220))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(220))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createProcessingInfoSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(120))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createActionsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 20, trailing: 16)
        
        return section
    }
    
    private func setupBindings() {
        dataManager.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
                self?.updateRefreshButton()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        if dataManager.datasets.isEmpty {
            dataManager.generateSampleData()
        }
    }
    
    private func updateRefreshButton() {
        refreshButton.isEnabled = !dataManager.isLoading
        refreshButton.alpha = dataManager.isLoading ? 0.6 : 1.0
    }
    
    @objc private func refreshTapped() {
        dataManager.refreshData()
    }
}

// MARK: - UICollectionViewDataSource

extension AnalyticsViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = Section(rawValue: section) else { return 0 }
        
        switch sectionType {
        case .stats:
            return 4 // Average, Maximum, Minimum, Data Points
        case .chart:
            return 1
        case .processingInfo:
            return 1
        case .actions:
            return 1
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sectionType = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        let stats = dataManager.stats
        
        switch sectionType {
        case .stats:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatisticCell", for: indexPath) as! StatisticCell
            
            switch indexPath.item {
            case 0:
                cell.configure(title: "Average", value: String(format: "%.1f", stats.average), color: .systemBlue)
            case 1:
                cell.configure(title: "Maximum", value: String(format: "%.1f", stats.maximum), color: .systemGreen)
            case 2:
                cell.configure(title: "Minimum", value: String(format: "%.1f", stats.minimum), color: .systemOrange)
            case 3:
                cell.configure(title: "Data Points", value: "\(stats.dataCount)", color: .systemPurple)
            default:
                break
            }
            
            return cell
            
        case .chart:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCell", for: indexPath) as! ChartCell
            cell.configure(dataset: dataManager.datasets.first, isLoading: dataManager.isLoading)
            return cell
            
        case .processingInfo:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProcessingInfoCell", for: indexPath) as! ProcessingInfoCell
            cell.configure()
            return cell
            
        case .actions:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActionCell", for: indexPath) as! ActionCell
            cell.configure(button: refreshButton)
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderView
        
        if let sectionType = Section(rawValue: indexPath.section) {
            header.configure(title: sectionType.title)
        }
        
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension AnalyticsViewController: UICollectionViewDelegate {
    
}

// MARK: - Custom Cells

class StatisticCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
        
        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textAlignment = .center
        
        addSubview(titleLabel)
        addSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            valueLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -12)
        ])
    }
    
    func configure(title: String, value: String, color: UIColor) {
        titleLabel.text = title
        valueLabel.text = value
        valueLabel.textColor = color
    }
}

class ChartCell: UICollectionViewCell {
    private let chartView = LineChartView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        loadingLabel.text = "Processing data with Objective-C..."
        loadingLabel.font = .systemFont(ofSize: 14)
        loadingLabel.textColor = .secondaryLabel
        loadingLabel.textAlignment = .center
        
        addSubview(chartView)
        addSubview(loadingView)
        addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            chartView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            chartView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            chartView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: 12),
            loadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            loadingLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    func configure(dataset: ChartDataset?, isLoading: Bool) {
        if isLoading {
            chartView.isHidden = true
            loadingView.isHidden = false
            loadingLabel.isHidden = false
            loadingView.startAnimating()
        } else {
            chartView.isHidden = false
            loadingView.isHidden = true
            loadingLabel.isHidden = true
            loadingView.stopAnimating()
            chartView.configure(dataset: dataset)
        }
    }
}

class ProcessingInfoCell: UICollectionViewCell {
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 12
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let items = [
            ("gear", "Processed using Objective-C DataProcessor", UIColor.systemBlue),
            ("chart.line.uptrend.xyaxis", "Data normalized and smoothed", UIColor.systemGreen),
            ("number", "Statistical analysis computed", UIColor.systemOrange)
        ]
        
        for (icon, text, color) in items {
            let itemView = createInfoItem(icon: icon, text: text, color: color)
            stackView.addArrangedSubview(itemView)
        }
    }
    
    private func createInfoItem(icon: String, text: String, color: UIColor) -> UIView {
        let containerView = UIView()
        
        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = color
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
}

class ActionCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Cell setup is minimal since button is added from outside
    }
    
    func configure(button: UIButton) {
        // Remove button from previous superview if any
        button.removeFromSuperview()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        addSubview(button)
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
}

class SectionHeaderView: UICollectionReusableView {
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(title: String) {
        titleLabel.text = title
        titleLabel.isHidden = title.isEmpty
    }
}

// MARK: - Custom Chart View

class LineChartView: UIView {
    private var dataset: ChartDataset?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(dataset: ChartDataset?) {
        self.dataset = dataset
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let dataset = dataset, !dataset.data.isEmpty else {
            drawNoDataMessage(in: rect)
            return
        }
        
        drawChart(dataset: dataset, in: rect)
    }
    
    private func drawNoDataMessage(in rect: CGRect) {
        let message = "No data available"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.secondaryLabel
        ]
        
        let size = message.size(withAttributes: attributes)
        let drawPoint = CGPoint(
            x: rect.midX - size.width / 2,
            y: rect.midY - size.height / 2
        )
        
        message.draw(at: drawPoint, withAttributes: attributes)
    }
    
    private func drawChart(dataset: ChartDataset, in rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let padding: CGFloat = 20
        let chartRect = rect.insetBy(dx: padding, dy: padding)
        
        // Find data bounds
        let maxX = dataset.data.map { $0.x }.max() ?? 1
        let maxY = dataset.data.map { $0.y }.max() ?? 1
        let minY = dataset.data.map { $0.y }.min() ?? 0
        let yRange = maxY - minY
        
        // Convert data points to screen coordinates
        let points = dataset.data.map { dataPoint in
            CGPoint(
                x: chartRect.minX + (dataPoint.x / maxX) * chartRect.width,
                y: chartRect.maxY - ((dataPoint.y - minY) / yRange) * chartRect.height
            )
        }
        
        // Draw line
        context.setStrokeColor(UIColor.systemBlue.cgColor)
        context.setLineWidth(2)
        context.setLineJoin(.round)
        context.setLineCap(.round)
        
        if let firstPoint = points.first {
            context.move(to: firstPoint)
            for point in points.dropFirst() {
                context.addLine(to: point)
            }
            context.strokePath()
        }
        
        // Draw data points
        context.setFillColor(UIColor.systemBlue.cgColor)
        for point in points {
            context.fillEllipse(in: CGRect(
                x: point.x - 3,
                y: point.y - 3,
                width: 6,
                height: 6
            ))
        }
    }
}