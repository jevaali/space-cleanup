

import Foundation

func printJson(_ data: Data) {
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        let prettyJsonData = try JSONSerialization.data(
            withJSONObject: jsonObject,
            options: .prettyPrinted
        )
        print(String(data: prettyJsonData, encoding: .utf8) ?? "")
    } catch {
        print("JSON print error:", error)
    }
}
