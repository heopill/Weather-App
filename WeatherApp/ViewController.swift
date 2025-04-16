//
//  ViewController.swift
//  WeatherApp
//
//  Created by 허성필 on 4/16/25.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private var dataSource = [ForecastWeather]()
    
    // URL 쿼리 아이템
    // 서울역 위도, 경도
    private let urlQueryItems: [URLQueryItem] = [
        URLQueryItem(name: "lat", value: "37.5"),
        URLQueryItem(name: "lon", value: "126.9"),
        URLQueryItem(name: "appid", value: "04c5eccbc834160ea1fe2d9fcd13e080"),
        URLQueryItem(name: "units", value: "metric"),
        
    ]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "서울특별시"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 30)
        return label
    }()
    
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.text = "20도"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 50)
        return label
    }()
    
    private let tempMinLabel = {
        let label = UILabel()
        label.text = "20도"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let tempMaxLabel = {
        let label = UILabel()
        label.text = "20도"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let tempStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        // delegate: 대리자, 대신 수행을 해주는 사람. tableView의 여러가지 속성 세팅을 이 ViewController에서 대신 세팅하는 코드를 작성해 주겠다.
        tableView.delegate = self
        // dataSource: 테이블 뷰 안에 집어넣을 데이터들. 이 ViewController
        tableView.dataSource = self
        // 테이블 뷰에다가 테이블 뷰 셀 등록
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.id)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCurrentWeatherData()
        fetchForeCastData()
    }
    
    // 서버 데이터를 불러오는 메서드 (재활용이 가능하도록 일반적인 함수로 작성)
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data, error == nil else {
                print("데이터 로드 실패")
                completion(nil)
                return
            }
            // http status code 성공 범위는 200번대.
            let successRange = 200..<300
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else {
                print("응답 오류")
                completion(nil)
            }
        }.resume()
    }
    
    // 서버에서 현재 날씨 데이터를 불러오는 메서드.
    private func fetchCurrentWeatherData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        urlComponents?.queryItems = self.urlQueryItems // url뒤 쿼리문에 알아서 key value 값으로 들어간다.
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: CurrentWeatherResult?) in
            guard let self, let result else { return }
            
            // UI를 그리는 작업은 메인 쓰레드에서 작업해야 하기 때문에 DispatchQueue로 사용
            DispatchQueue.main.async {
                self.tempLabel.text = "\(Int(result.main.temp))°C"
                self.tempMinLabel.text = "최소 : \(Int(result.main.tempMin))°C"
                self.tempMaxLabel.text = "최고 : \(Int(result.main.tempMax))°C"
            }
            
            guard let imageUrl = URL(string: "https://openweathermap.org/img/wn/\(result.weather[0].icon)@2x.png") else {
                return
            }
            
            // 이미지를 로드하는 작업은 백드라운드 쓰레드 작업
            if let data = try? Data(contentsOf: imageUrl) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async{
                        self.imageView.image = image
                    }
                }
            }
                                     

        }
    }
    
    // 서버에서 5일 간 날씨 예보 데이터를 불러오는 메서드
    private func fetchForeCastData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        urlComponents?.queryItems = self.urlQueryItems
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: ForecastWeatherResult?) in
            guard let self, let result else { return }
            
            // 콘솔에다가 데이터를 잘 불러왔는지 찍어보기
            for forecastWeather in result.list {
                print("\(forecastWeather.main)\n\(forecastWeather.dtTxt)\n\n")
            }
            
            DispatchQueue.main.async {
                self.dataSource = result.list
                self.tableView.reloadData()
            }
        }
    }
    
    
    private func configureUI() {
        view.backgroundColor = .black
        
        [titleLabel, tempLabel, tempStackView ,imageView, tableView].forEach { view.addSubview($0) }
        
        [tempMinLabel, tempMaxLabel].forEach { tempStackView.addArrangedSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(120)
        }
        
        tempLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        tempStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(tempLabel.snp.bottom).offset(10)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(160)
            make.top.equalTo(tempStackView.snp.bottom).offset(20)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(50)
        }
    }
}

extension ViewController: UITableViewDelegate {
    // 테이블 뷰 셀 높이 크기 지정.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
}


extension ViewController: UITableViewDataSource {
    // 테이블 뷰 섹션에 행이 몇 개 들어가는가. 여기서 섹션은 없으니 그냥 총 행 개수를 입력하면 됩니다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    // 테이블 뷰의 indexPath마다 테이블 뷰 셀을 지정.
    // indexPath = 테이블 뷰의 행과 섹션을 의미.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.id) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(forecastWeather: dataSource[indexPath.row])
        return cell
                
    }
    
    
}
