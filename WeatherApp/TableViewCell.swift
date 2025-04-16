//
//  TableViewCell.swift
//  WeatherApp
//
//  Created by 허성필 on 4/16/25.
//

import UIKit
import SnapKit

final class TableViewCell: UITableViewCell {
    
    static let id = "TableViewCell"
    
    private let dtTxtLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .black
        label.textColor = .white
        return label
    }()
    
    // 테이블 뷰의 스타일과 id로 초기화를 할 때 사용하는 코드.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureUI()
    }
    
    // 인터페이스 빌더를 통해 셀을 초기화 할 때 사용하는 코드.
    // 여기서는 fatalError를 통해 명시적으로 인터페이스 빌더로 쵝화 하지 않음을 나타냄.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.backgroundColor = .black
        [ dtTxtLabel, tempLabel ].forEach { contentView.addSubview($0) }
        
        dtTxtLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    public func configureCell(forecastWeather: ForecastWeather) {
        dtTxtLabel.text = "\(forecastWeather.dtTxt)"
        tempLabel.text = "\(forecastWeather.main.temp)°C"
    }
}
