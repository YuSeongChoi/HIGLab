extension BluetoothManager {
    func readValue(from characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        peripheral.readValue(for: characteristic)
    }
    
    func writeValue(_ data: Data, to characteristic: CBCharacteristic, peripheral: CBPeripheral) {
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        print("받은 데이터: \(data)")
    }
}
