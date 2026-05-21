import SwiftUI

@Observable
class AppLocalization {
    static let shared = AppLocalization()
    var isHindi = false

    func localized(_ key: String) -> String {
        guard isHindi else { return key }
        return hindiStrings[key] ?? key
    }

    private let hindiStrings: [String: String] = [
        "Programme": "कार्यक्रम",
        "Speakers": "वक्ता",
        "Locations": "स्थान",
        "My Schedule": "मेरा शेड्यूल",
        "No Favourites Yet": "अभी तक कोई पसंदीदा नहीं",
        "Tap the star on any session in the Programme to save it here.": "यहाँ सहेजने के लिए कार्यक्रम में किसी भी सत्र पर स्टार टैप करें।",
        "Search speakers": "वक्ता खोजें",
        "Added to favourites": "पसंदीदा में जोड़ा गया",
        "Removed from favourites": "पसंदीदा से हटाया गया",
        "Add to favourites": "पसंदीदा में जोड़ें",
        "Remove from favourites": "पसंदीदा से हटाएं",
        "Open in Maps": "मैप्स में खोलें",
        "Talk": "वार्ता",
        "Workshop": "कार्यशाला",
        "Discussion Panel": "चर्चा पैनल",
        "Tea / Coffee Break": "चाय/कॉफ़ी ब्रेक",
        "Lunch": "दोपहर का भोजन",
        "Lightning Talks": "लाइटनिंग टॉक्स",
        "Registration": "पंजीकरण",
        "Social Event": "सामाजिक कार्यक्रम",
        "Conference Dinner": "सम्मेलन रात्रिभोज",
        "Rail Trip": "रेल यात्रा",
        "Enable reading-friendly font": "पठन-अनुकूल फ़ॉन्ट सक्षम करें",
        "Disable reading-friendly font": "पठन-अनुकूल फ़ॉन्ट अक्षम करें",
        "MythConf 2026": "मिथकॉन्फ़ 2026"
    ]
}
