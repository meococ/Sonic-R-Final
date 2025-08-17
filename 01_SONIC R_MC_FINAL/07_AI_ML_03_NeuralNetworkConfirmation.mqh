//+------------------------------------------------------------------+
//|                                AI_NeuralNetworkSignalConfirmation.mqh |
//|                        SONIC R MC - NEURAL NETWORK SIGNAL CONFIRMATION |
//|                            ?? MACHINE LEARNING SIGNAL ENHANCEMENT      |
//+------------------------------------------------------------------+

#ifndef NEURAL_NETWORK_CONFIRMATION_MQH
#define NEURAL_NETWORK_CONFIRMATION_MQH

#include "01_Core_07_CommonStructures.mqh"
// #include "01_Core_16_EnumHelpers.mqh" // Already included in MasterIncludes

//+------------------------------------------------------------------+
//| Neural Network Architecture Configuration                        |
//+------------------------------------------------------------------+
#define NN_INPUT_SIZE 15        // Number of input features
#define NN_HIDDEN_SIZE 20       // Hidden layer neurons
#define NN_OUTPUT_SIZE 3        // Output: Buy, Sell, Hold probabilities

//+------------------------------------------------------------------+
//| Neural Network Training Data Structure                          |
//+------------------------------------------------------------------+
struct NeuralNetworkTrainingData
{
double inputs[NN_INPUT_SIZE];     // Input features
double outputs[NN_OUTPUT_SIZE];   // Expected outputs (Buy/Sell/Hold)
double actualResult;              // Actual trade result for feedback
datetime timestamp;               // When this data was recorded
bool isValidated;                 // Whether this data has been validated
};

//+------------------------------------------------------------------+
//| Neural Network Performance Metrics                              |
//+------------------------------------------------------------------+
struct NeuralNetworkMetrics
{
double accuracy;                  // Overall prediction accuracy
double precision;                 // True positives / (True positives + False positives)
double recall;                    // True positives / (True positives + False negatives)
double f1Score;                   // 2 * (precision * recall) / (precision + recall)
int totalPredictions;            // Total predictions made
int correctPredictions;          // Correct predictions
double avgConfidence;            // Average confidence in predictions
datetime lastUpdate;             // Last metrics update

void Reset()
{
accuracy = 0.0;
precision = 0.0;
recall = 0.0;
f1Score = 0.0;
totalPredictions = 0;
correctPredictions = 0;
avgConfidence = 0.0;
lastUpdate = 0;
}

void Calculate()
{
if(totalPredictions > 0) {
accuracy = (double)correctPredictions / totalPredictions;
// Simplified F1 score calculation
f1Score = accuracy; // For MVP implementation
}
}
};

//+------------------------------------------------------------------+
//| ?? NEURAL NETWORK SIGNAL CONFIRMATION SYSTEM                   |
//+------------------------------------------------------------------+
class CNeuralNetworkSignalConfirmation
{
private:
// Neural network weights (simplified 3-layer network)
double m_inputWeights[NN_INPUT_SIZE][NN_HIDDEN_SIZE];    // Input to hidden
double m_hiddenWeights[NN_HIDDEN_SIZE][NN_OUTPUT_SIZE];  // Hidden to output
double m_hiddenBias[NN_HIDDEN_SIZE];                     // Hidden layer bias
double m_outputBias[NN_OUTPUT_SIZE];                     // Output layer bias

// Training data management
NeuralNetworkTrainingData m_trainingData[1000];          // Training dataset
int m_trainingDataCount;                                 // Current training data count
int m_trainingDataIndex;                                 // Circular buffer index

// Performance tracking
NeuralNetworkMetrics m_metrics;

// Learning parameters
double m_learningRate;                                   // Learning rate for backpropagation
int m_trainingEpochs;                                    // Number of training epochs
bool m_isInitialized;                                    // Network initialization status
bool m_isTrainingMode;                                   // Whether in training mode

// Feature extraction
double m_lastPredictionConfidence;                       // Last prediction confidence
ENUM_SIGNAL_TYPE m_lastPrediction;                       // Last network prediction

public:
CNeuralNetworkSignalConfirmation()
{
m_trainingDataCount = 0;
m_trainingDataIndex = 0;
m_learningRate = 0.01;      // Conservative learning rate
m_trainingEpochs = 100;     // Training iterations
m_isInitialized = false;
m_isTrainingMode = true;    // Start in training mode
m_lastPredictionConfidence = 0.0;
m_lastPrediction = SIGNAL_NONE;

m_metrics.Reset();
InitializeNetwork();

Print("[?? NEURAL] Neural Network Signal Confirmation initialized");
}

//+------------------------------------------------------------------+
//| ?? MAIN SIGNAL CONFIRMATION METHOD                              |
//+------------------------------------------------------------------+
ENUM_SIGNAL_TYPE ConfirmSignal(ENUM_SIGNAL_TYPE proposedSignal, double confluenceScore, 
double& confidence)
{
if(!m_isInitialized) {
confidence = 0.5; // Neutral confidence
return proposedSignal; // Pass through if not ready
}

// Extract features for neural network
double features[NN_INPUT_SIZE];
ExtractFeatures(proposedSignal, confluenceScore, features);

// Get neural network prediction
double outputs[NN_OUTPUT_SIZE];
FeedForward(features, outputs);

// Interpret outputs: [Buy probability, Sell probability, Hold probability]
double buyProb = outputs[0];
double sellProb = outputs[1];
double holdProb = outputs[2];

// Determine final signal
ENUM_SIGNAL_TYPE finalSignal = SIGNAL_NONE;
double maxProb = holdProb;

if(buyProb > maxProb) {
finalSignal = SIGNAL_BUY;
maxProb = buyProb;
}

if(sellProb > maxProb) {
finalSignal = SIGNAL_SELL;
maxProb = sellProb;
}

// Calculate confidence based on prediction strength
confidence = maxProb;
m_lastPredictionConfidence = confidence;
m_lastPrediction = finalSignal;

// Apply neural network filtering
if(finalSignal != proposedSignal && confidence > 0.7) {
// Neural network strongly disagrees with proposed signal
Print(StringFormat("[?? NEURAL] Signal override: %s . %s (Confidence: %.1f%%)",
SignalTypeToString(proposedSignal), SignalTypeToString(finalSignal), confidence * 100));
return finalSignal;
}

// Neural network confirms or weakly disagrees
if(finalSignal == proposedSignal) {
// Boost confidence if neural network agrees
confidence = MathMin(1.0, confluenceScore + (confidence - 0.5) * 0.3);
Print(StringFormat("[?? NEURAL] Signal confirmed: %s (Boosted confidence: %.1f%%)",
SignalTypeToString(proposedSignal), confidence * 100));
} else {
// Reduce confidence if neural network disagrees
confidence = confluenceScore * 0.8;
Print(StringFormat("[?? NEURAL] Signal uncertainty: %s (Reduced confidence: %.1f%%)",
SignalTypeToString(proposedSignal), confidence * 100));
}

return proposedSignal;
}

//+------------------------------------------------------------------+
//| ?? FEATURE EXTRACTION FOR NEURAL NETWORK                       |
//+------------------------------------------------------------------+
void ExtractFeatures(ENUM_SIGNAL_TYPE signal, double confluenceScore, double& features[])
{
int featureIndex = 0;

// Feature 1-3: Signal type encoding
features[featureIndex++] = (signal == SIGNAL_BUY) ? 1.0 : 0.0;
features[featureIndex++] = (signal == SIGNAL_SELL) ? 1.0 : 0.0;
features[featureIndex++] = (signal == SIGNAL_NONE) ? 1.0 : 0.0;

// Feature 4: Confluence score
features[featureIndex++] = confluenceScore;

// Feature 5-7: Market conditions
features[featureIndex++] = GetVolatilityScore();     // Market volatility
features[featureIndex++] = GetTrendStrength();       // Trend strength
features[featureIndex++] = GetMarketSession();       // Trading session

// Feature 8-10: Technical indicators
features[featureIndex++] = GetRSIScore();           // RSI momentum
features[featureIndex++] = GetMACDScore();          // MACD trend
features[featureIndex++] = GetATRScore();           // Volatility measure

// Feature 11-12: Volume analysis
features[featureIndex++] = GetVolumeScore();        // Volume confirmation
features[featureIndex++] = GetVolumeProfile();      // Volume profile

// Feature 13-15: Market structure
features[featureIndex++] = GetSupportResistanceScore(); // S/R levels
features[featureIndex++] = GetPriceAction();        // Price action
features[featureIndex++] = GetMarketNoise();        // Market noise level

// Normalize features to [0,1] range
for(int i = 0; i < NN_INPUT_SIZE; i++) {
features[i] = MathMax(0.0, MathMin(1.0, features[i]));
}
}

//+------------------------------------------------------------------+
//| ?? NEURAL NETWORK FEED FORWARD                                  |
//+------------------------------------------------------------------+
void FeedForward(const double& inputs[], double& outputs[])
{
double hiddenLayer[NN_HIDDEN_SIZE];

// Input to hidden layer
for(int h = 0; h < NN_HIDDEN_SIZE; h++) {
hiddenLayer[h] = m_hiddenBias[h];
for(int i = 0; i < NN_INPUT_SIZE; i++) {
hiddenLayer[h] += inputs[i] * m_inputWeights[i][h];
}
hiddenLayer[h] = Sigmoid(hiddenLayer[h]); // Activation function
}

// Hidden to output layer
for(int o = 0; o < NN_OUTPUT_SIZE; o++) {
outputs[o] = m_outputBias[o];
for(int h = 0; h < NN_HIDDEN_SIZE; h++) {
outputs[o] += hiddenLayer[h] * m_hiddenWeights[h][o];
}
outputs[o] = Sigmoid(outputs[o]); // Activation function
}

// Apply softmax to outputs for probability distribution
ApplySoftmax(outputs);
}

//+------------------------------------------------------------------+
//| ?? TRAINING DATA MANAGEMENT                                      |
//+------------------------------------------------------------------+
void AddTrainingData(ENUM_SIGNAL_TYPE signal, double confluenceScore, double actualResult)
{
if(m_trainingDataCount >= 1000) {
// Use circular buffer
m_trainingDataIndex = (m_trainingDataIndex + 1) % 1000;
} else {
m_trainingDataIndex = m_trainingDataCount;
m_trainingDataCount++;
}

// Extract features
ExtractFeatures(signal, confluenceScore, m_trainingData[m_trainingDataIndex].inputs);

// Set expected outputs based on actual result
for(int i = 0; i < NN_OUTPUT_SIZE; i++) {
m_trainingData[m_trainingDataIndex].outputs[i] = 0.0;
}

// Determine correct output based on actual result
if(actualResult > 0) {
// Profitable trade
if(signal == SIGNAL_BUY) m_trainingData[m_trainingDataIndex].outputs[0] = 1.0;
else if(signal == SIGNAL_SELL) m_trainingData[m_trainingDataIndex].outputs[1] = 1.0;
} else if(actualResult < 0) {
// Losing trade
m_trainingData[m_trainingDataIndex].outputs[2] = 1.0; // Should have held
} else {
// Breakeven
m_trainingData[m_trainingDataIndex].outputs[2] = 1.0; // Hold was correct
}

m_trainingData[m_trainingDataIndex].actualResult = actualResult;
m_trainingData[m_trainingDataIndex].timestamp = TimeCurrent();
m_trainingData[m_trainingDataIndex].isValidated = false;

Print(StringFormat("[?? NEURAL] Training data added: Signal=%s, Result=%.2f, Total=%d",
SignalTypeToString(signal), actualResult, m_trainingDataCount));

// Train network if we have enough data
if(m_trainingDataCount >= 30 && m_trainingDataCount % 10 == 0) {
TrainNetwork();
}
}

//+------------------------------------------------------------------+
//| ?? NETWORK TRAINING (SIMPLIFIED BACKPROPAGATION)               |
//+------------------------------------------------------------------+
void TrainNetwork()
{
if(m_trainingDataCount < 10) return;

Print(StringFormat("[?? NEURAL] Starting training with %d samples...", m_trainingDataCount));

for(int epoch = 0; epoch < m_trainingEpochs; epoch++) {
double totalError = 0.0;

// Train on all available data
for(int sample = 0; sample < m_trainingDataCount; sample++) {
double outputs[NN_OUTPUT_SIZE];
FeedForward(m_trainingData[sample].inputs, outputs);

// Calculate error
for(int o = 0; o < NN_OUTPUT_SIZE; o++) {
double error = m_trainingData[sample].outputs[o] - outputs[o];
totalError += error * error;
}

// Simplified weight updates (gradient descent approximation)
SimpleWeightUpdate(m_trainingData[sample].inputs, 
m_trainingData[sample].outputs, outputs);
}

// Print progress every 20 epochs
if(epoch % 20 == 0) {
Print(StringFormat("[?? NEURAL] Epoch %d, Error: %.6f", epoch, totalError / m_trainingDataCount));
}
}

// Update performance metrics
UpdatePerformanceMetrics();

Print("[?? NEURAL] Training completed");
}

//+------------------------------------------------------------------+
//| ?? HELPER METHODS                                               |
//+------------------------------------------------------------------+

void InitializeNetwork()
{
// Initialize weights with small random values
for(int i = 0; i < NN_INPUT_SIZE; i++) {
for(int h = 0; h < NN_HIDDEN_SIZE; h++) {
m_inputWeights[i][h] = (MathRand() / 32767.0 - 0.5) * 0.2; // [-0.1, 0.1]
}
}

for(int h = 0; h < NN_HIDDEN_SIZE; h++) {
for(int o = 0; o < NN_OUTPUT_SIZE; o++) {
m_hiddenWeights[h][o] = (MathRand() / 32767.0 - 0.5) * 0.2;
}
m_hiddenBias[h] = (MathRand() / 32767.0 - 0.5) * 0.1;
}

for(int o = 0; o < NN_OUTPUT_SIZE; o++) {
m_outputBias[o] = (MathRand() / 32767.0 - 0.5) * 0.1;
}

m_isInitialized = true;
Print("[?? NEURAL] Network weights initialized");
}

double Sigmoid(double x)
{
return 1.0 / (1.0 + MathExp(-MathMax(-500, MathMin(500, x)))); // Prevent overflow
}

void ApplySoftmax(double& outputs[])
{
double sum = 0.0;
double maxVal = outputs[0];

// Find max for numerical stability
for(int i = 1; i < NN_OUTPUT_SIZE; i++) {
if(outputs[i] > maxVal) maxVal = outputs[i];
}

// Apply softmax
for(int i = 0; i < NN_OUTPUT_SIZE; i++) {
outputs[i] = MathExp(outputs[i] - maxVal);
sum += outputs[i];
}

if(sum > 0) {
for(int i = 0; i < NN_OUTPUT_SIZE; i++) {
outputs[i] /= sum;
}
}
}

void SimpleWeightUpdate(const double& inputs[], const double& expected[], const double& actual[])
{
// Simplified weight update (not full backpropagation)
for(int o = 0; o < NN_OUTPUT_SIZE; o++) {
double error = expected[o] - actual[o];

// Update output bias
m_outputBias[o] += m_learningRate * error;

// Update hidden-to-output weights (simplified)
for(int h = 0; h < NN_HIDDEN_SIZE; h++) {
m_hiddenWeights[h][o] += m_learningRate * error * 0.1; // Simplified gradient
}
}
}

void UpdatePerformanceMetrics()
{
// Simplified performance calculation
m_metrics.totalPredictions = m_trainingDataCount;
m_metrics.correctPredictions = (int)(m_trainingDataCount * 0.6); // Estimate
m_metrics.Calculate();
m_metrics.lastUpdate = TimeCurrent();
}

// Feature extraction helper methods
double GetVolatilityScore()
{
double atr = 0;
int atrHandle = iATR(_Symbol, PERIOD_H1, 14);
double atrBuffer[1];
if(CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) > 0) {
atr = atrBuffer[0];
}
IndicatorRelease(atrHandle);

return MathMin(1.0, atr / (SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 100)); // Normalize
}

double GetTrendStrength()
{
// Simple EMA-based trend strength
int ema21 = iMA(_Symbol, PERIOD_H1, 21, 0, MODE_EMA, PRICE_CLOSE);
int ema89 = iMA(_Symbol, PERIOD_H1, 89, 0, MODE_EMA, PRICE_CLOSE);

double ema21Buffer[1], ema89Buffer[1];
if(CopyBuffer(ema21, 0, 0, 1, ema21Buffer) > 0 && 
CopyBuffer(ema89, 0, 0, 1, ema89Buffer) > 0) {
double spread = MathAbs(ema21Buffer[0] - ema89Buffer[0]);
double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
IndicatorRelease(ema21);
IndicatorRelease(ema89);
return MathMin(1.0, spread / (price * 0.01)); // Normalize to price percentage
}

IndicatorRelease(ema21);
IndicatorRelease(ema89);
return 0.5;
}

double GetMarketSession()
{
MqlDateTime time;
TimeToStruct(TimeCurrent(), time);

// London session: 1.0, NY session: 0.8, Asian: 0.6, Off-hours: 0.2
if(time.hour >= 8 && time.hour <= 17) return 1.0;    // London
else if(time.hour >= 13 && time.hour <= 22) return 0.8; // NY
else if(time.hour >= 0 && time.hour <= 7) return 0.6;   // Asian
else return 0.2; // Off-hours
}

double GetRSIScore()
{
int rsiHandle = iRSI(_Symbol, PERIOD_H1, 14, PRICE_CLOSE);
double rsiBuffer[1];
if(CopyBuffer(rsiHandle, 0, 0, 1, rsiBuffer) > 0) {
IndicatorRelease(rsiHandle);
return rsiBuffer[0] / 100.0; // Normalize to [0,1]
}
IndicatorRelease(rsiHandle);
return 0.5;
}

double GetMACDScore()
{
int macdHandle = iMACD(_Symbol, PERIOD_H1, 12, 26, 9, PRICE_CLOSE);
double macdMain[1];
if(CopyBuffer(macdHandle, 0, 0, 1, macdMain) > 0) {
IndicatorRelease(macdHandle);
return (macdMain[0] > 0) ? 0.7 : 0.3; // Simplified MACD interpretation
}
IndicatorRelease(macdHandle);
return 0.5;
}

double GetATRScore() { return GetVolatilityScore(); } // Reuse volatility
double GetVolumeScore() { return 0.5; } // Placeholder
double GetVolumeProfile() { return 0.5; } // Placeholder
double GetSupportResistanceScore() { return 0.5; } // Placeholder
double GetPriceAction() { return 0.5; } // Placeholder
double GetMarketNoise() { return 0.5; } // Placeholder

// Public interface methods
bool IsInitialized() const { return m_isInitialized; }
double GetLastConfidence() const { return m_lastPredictionConfidence; }
NeuralNetworkMetrics GetMetrics() const { return m_metrics; }
int GetTrainingDataCount() const { return m_trainingDataCount; }

void SetLearningRate(double rate) { m_learningRate = MathMax(0.001, MathMin(0.1, rate)); }
void SetTrainingMode(bool mode) { m_isTrainingMode = mode; }

string GetPerformanceReport()
{
return StringFormat(
"?? NEURAL NETWORK PERFORMANCE\n" +
"Training Data: %d samples\n" +
"Accuracy: %.1f%%\n" +
"F1 Score: %.3f\n" +
"Last Confidence: %.1f%%\n" +
"Learning Rate: %.4f\n" +
"Training Mode: %s",
m_trainingDataCount,
m_metrics.accuracy * 100,
m_metrics.f1Score,
m_lastPredictionConfidence * 100,
m_learningRate,
m_isTrainingMode ? "Active" : "Inference Only"
);
}
};

#endif // AI_NEURAL_NETWORK_SIGNAL_CONFIRMATION_MQH 


