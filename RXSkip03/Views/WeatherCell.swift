//
//  WeatherCell.swift
//  RXSkip03
//
//  Created by Скіп Юлія Ярославівна on 09.02.2026.
//
import UIKit

class WeatherCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayTempLabel: UILabel!
    @IBOutlet weak var nightTempLabel: UILabel!
    @IBOutlet weak var rainIcon: UIImageView!
    
    private var gradientLayer: CAGradientLayer = CAGradientLayer()
    
    override func prepareForReuse(){
        super.prepareForReuse()
        weatherIcon.image = nil
        rainIcon.isHidden = true
    }
    
    func config(with forecast: DayForecast) {
        dayTempLabel.text = "\(forecast.dayTemp ?? 0.0)°"
        nightTempLabel.text = "\(forecast.nightTemp ?? 0.0)°"
        windSpeedLabel.text = "༄ \(forecast.windSpeed ?? 0.0) м/с"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, d MMM"
        formatter.locale = Locale(identifier: "uk_UA")
        if let date = forecast.date{
            dateLabel.text = formatter.string(from: date)
        }else{
            dateLabel.text = "--, - ---"
        }
        
        //апішка з іконками стану погоди чогось працювала тільки для однієї з них,
        //тому я просто скачала їх в асети і тягну звідти
        if let icon = forecast.icon {
            weatherIcon.image = UIImage(named: icon)
        }
        
        if let rainVolume = forecast.rainVolume {
            rainIcon.isHidden = !(rainVolume > 0.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: 250)
        setupCellDesign()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = cellView.bounds
        
        let padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        contentView.frame = contentView.frame.inset(by: padding)
        
    }
    
    private func setupCellDesign() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        cellView.layer.cornerRadius = 25
        cellView.layer.masksToBounds = true
        cellView.backgroundColor = .clear
        
        gradientLayer.colors = [
            UIColor(red: 155/255, green: 170/255, blue: 255/255, alpha: 0.8).cgColor,
            UIColor(red: 5/255, green: 20/255, blue: 100/255, alpha: 0.8).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        gradientLayer.frame = cellView.bounds
        
        if gradientLayer.superlayer == nil {
            cellView.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
