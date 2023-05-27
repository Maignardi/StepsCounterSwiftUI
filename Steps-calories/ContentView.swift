import SwiftUI
import CoreMotion

struct ContentView: View {
    @State private var stepCount: Int = 0
    @State private var caloriesBurned: Double = 0
    
    private let pedometer = CMPedometer()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text("Contador de Passos")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            Spacer()
            
            Text("\(stepCount)")
                .font(.system(size: 100, weight: .bold, design: .default))
                .padding(.bottom, 20)
            
            Text("Passos")
                .font(.title)
            
            Spacer()
            
            Text("Calorias Gastas")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(caloriesBurned, specifier: "%.2f")")
                .font(.system(size: 40, weight: .bold, design: .default))
            
            Spacer()
        }
        .padding()
        .foregroundColor(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onAppear(perform: {
            startCountingSteps()
        })
        .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
            resetCounters()
        }
    }
    
    private func startCountingSteps() {
        resetCounters()
        
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        if CMPedometer.isStepCountingAvailable() {
            pedometer.queryPedometerData(from: startOfDay, to: endOfDay) { pedometerData, error in
                if let data = pedometerData {
                    DispatchQueue.main.async {
                        self.stepCount = data.numberOfSteps.intValue
                        if let distance = data.distance {
                            // Assumindo uma pessoa de 84 kg
                            self.caloriesBurned = distance.doubleValue * 0.06 * 84.0 / 70.0
                        }
                    }
                }
            }
            
            pedometer.startUpdates(from: startOfDay) { pedometerData, error in
                if let data = pedometerData {
                    DispatchQueue.main.async {
                        self.stepCount = data.numberOfSteps.intValue
                        if let distance = data.distance {
                            // Assumindo uma pessoa de 84 kg
                            self.caloriesBurned = distance.doubleValue * 0.06 * 84.0 / 70.0
                        }
                    }
                }
            }
        }
    }
    
    private func resetCounters() {
        stepCount = 0
        caloriesBurned = 0
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
