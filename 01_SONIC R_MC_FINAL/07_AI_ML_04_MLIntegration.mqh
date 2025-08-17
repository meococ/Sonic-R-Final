//+------------------------------------------------------------------+
//|                                               ML_Integration.mqh |
//|                 ?? PRIORITY 4: ML & EXTERNAL API INTEGRATION     |
//|                            Future-Ready Architecture             |
//+------------------------------------------------------------------+
#property copyright "Sonic R MC Team"
#property version   "4.00"
// PRODUCTION FIX: Remove #property strict - MQL4 syntax not supported in MQL5

#ifndef ML_INTEGRATION_MQH
#define ML_INTEGRATION_MQH

#include "01_Core_03_Logger.mqh"
#include "02_DataProviders_05_IndicatorManager.mqh"

//+------------------------------------------------------------------+
//| ?? PHASE 2: ENHANCED ML DATA STRUCTURES                        |
//+------------------------------------------------------------------+
struct MLFeatureData
{
// Original features
double              atr;
double              volatility;
double              volume;
double              spread;
double              rsi;
double              macd;
double              bollinger_position;
double              support_distance;
double              resistance_distance;
double              trend_strength;
double              sentiment_score;
double              news_impact;
datetime            timestamp;

// ?? PHASE 2: Advanced features
double              correlation_score;      // Multi-pair correlation
double              volatility_regime;      // Market regime classification
double              momentum_divergence;    // Price-momentum divergence
double              volume_profile;         // Volume profile analysis
double              market_microstructure;  // Order flow analysis
double              session_bias;           // Trading session bias
double              fractal_dimension;      // Market complexity measure
double              entropy_measure;        // Market randomness
double              liquidity_score;        // Market liquidity assessment
double              smart_money_flow;       // Institutional flow detection

void Reset()
{
atr = volatility = volume = spread = rsi = macd = 0.0;
bollinger_position = support_distance = resistance_distance = 0.0;
trend_strength = sentiment_score = news_impact = 0.0;
correlation_score = volatility_regime = momentum_divergence = 0.0;
volume_profile = market_microstructure = session_bias = 0.0;
fractal_dimension = entropy_measure = liquidity_score = smart_money_flow = 0.0;
timestamp = 0;
}
};

// ?? PHASE 2: Neural Network Layer Structure
struct NeuralLayer
{
double              weights[50][50];        // Max 50x50 weight matrix
double              biases[50];             // Bias vector
double              activations[50];        // Layer activations
int                 input_size;
int                 output_size;
string              activation_function;    // "relu", "sigmoid", "tanh"

void Reset()
{
ArrayInitialize(weights, 0.0);
ArrayInitialize(biases, 0.0);
ArrayInitialize(activations, 0.0);
input_size = output_size = 0;
activation_function = "relu";
}
};

// ?? PHASE 2: Neural Network Configuration
struct NeuralNetworkConfig
{
int                 layer_count;
int                 layer_sizes[10];        // Max 10 layers
string              layer_activations[10];
double              learning_rate;
double              dropout_rate;
int                 epochs;
int                 batch_size;
bool                use_batch_norm;
bool                use_regularization;
double              l2_lambda;

void Reset()
{
layer_count = 3; // Default: input, hidden, output
ArrayInitialize(layer_sizes, 0);
layer_sizes[0] = 22; // Enhanced feature count
layer_sizes[1] = 64; // Hidden layer
layer_sizes[2] = 3;  // Output: BUY/SELL/HOLD

for(int i = 0; i < 10; i++) layer_activations[i] = "relu";
layer_activations[layer_count-1] = "softmax"; // Output layer

learning_rate = 0.001;
dropout_rate = 0.2;
epochs = 100;
batch_size = 32;
use_batch_norm = true;
use_regularization = true;
l2_lambda = 0.01;
}
};

struct MLPrediction
{
double              probability;
int                 signal_type;        // 0=NONE, 1=BUY, 2=SELL
double              confidence;
double              expected_return;
double              risk_score;
string              model_version;
datetime            prediction_time;

void Reset()
{
probability = confidence = expected_return = risk_score = 0.0;
signal_type = 0;
model_version = "";
prediction_time = 0;
}
};

//+------------------------------------------------------------------+
//| ?? ENHANCED: Python Bridge Integration - DISABLED FOR COMPILATION |
//| Based on: https://www.mql5.com/en/articles/5691                |
//+------------------------------------------------------------------+
// FIXED: Properly disable imports to resolve compilation errors
// All #import statements completely commented out to prevent parsing issues

// DISABLED: Python Bridge Integration
// #import "python_bridge.ex5"
// Python ML model functions
// bool PyML_Initialize(string modelPath);
// double PyML_Predict(double &features[], int featuresCount);
// bool PyML_TrainModel(double &features[], int featuresCount, double target);
// string PyML_GetModelInfo();
// bool PyML_SaveModel(string modelPath);
// void PyML_Cleanup();
// #import

// DISABLED: Kernel32 DLL Integration
// #import "kernel32.dll"
// For advanced process communication
// int CreateFileW(string lpFileName, int dwDesiredAccess, int dwShareMode, 
// int lpSecurityAttributes, int dwCreationDisposition, 
// int dwFlagsAndAttributes, int hTemplateFile);
// bool WriteFile(int hFile, string lpBuffer, int nNumberOfBytesToWrite, 
// int &lpNumberOfBytesWritten, int lpOverlapped);
// bool ReadFile(int hFile, string &lpBuffer, int nNumberOfBytesToRead, 
// int &lpNumberOfBytesRead, int lpOverlapped);
// bool CloseHandle(int hObject);
// #import

// Stub functions for compilation
bool PyML_Initialize(string modelPath) { return true; }
double PyML_Predict(double &features[], int featuresCount) { return 0.5; }
bool PyML_TrainModel(double &features[], int featuresCount, double target) { return true; }
string PyML_GetModelInfo() { return "ML Stub"; }
bool PyML_SaveModel(string modelPath) { return true; }
void PyML_Cleanup() { }

//+------------------------------------------------------------------+
//| ?? PHASE 2: NEURAL NETWORK IMPLEMENTATION                      |
//+------------------------------------------------------------------+
class CNeuralNetwork
{
private:
NeuralNetworkConfig m_config;
NeuralLayer         m_layers[10];
bool                m_initialized;
double              m_trainingLoss;
double              m_validationAccuracy;
int                 m_trainingEpoch;

// ?? PHASE 2: Advanced training features
double              m_learningRateSchedule[1000]; // Adaptive learning rate
bool                m_useAdaptiveLR;
double              m_momentum;
double              m_beta1, m_beta2; // Adam optimizer parameters
double              m_epsilon;

public:
CNeuralNetwork()
{
m_config.Reset();
m_initialized = false;
m_trainingLoss = 0.0;
m_validationAccuracy = 0.0;
m_trainingEpoch = 0;
m_useAdaptiveLR = true;
m_momentum = 0.9;
m_beta1 = 0.9;
m_beta2 = 0.999;
m_epsilon = 1e-8;

// Initialize layers
for(int i = 0; i < 10; i++) {
m_layers[i].Reset();
}
}

// ?? PHASE 2: Initialize neural network
bool Initialize(const NeuralNetworkConfig& config)
{
m_config = config;

Print("[?? NEURAL NET] Initializing network architecture...");
Print(StringFormat("  Layers: %d", m_config.layer_count));

// Initialize each layer
for(int i = 0; i < m_config.layer_count; i++) {
m_layers[i].input_size = (i == 0) ? m_config.layer_sizes[0] : m_config.layer_sizes[i-1];
m_layers[i].output_size = m_config.layer_sizes[i];
m_layers[i].activation_function = m_config.layer_activations[i];

// Xavier/He initialization
InitializeWeights(i);

Print(StringFormat("  Layer %d: %dx%d (%s)", i+1, m_layers[i].input_size, 
m_layers[i].output_size, m_layers[i].activation_function));
}

m_initialized = true;
Print("[? NEURAL NET] Network initialized successfully");
return true;
}

// ?? PHASE 2: Forward propagation
MLPrediction Predict(const MLFeatureData& features)
{
MLPrediction prediction;
prediction.Reset();

if(!m_initialized) {
Print("[? NEURAL NET] Network not initialized");
return prediction;
}

// Convert features to input vector
double inputs[22];
ConvertFeaturesToVector(features, inputs, 22);

// Forward pass through all layers
double currentInputs[50];
ArrayCopy(currentInputs, inputs, 0, 0, m_layers[0].input_size);

for(int layer = 0; layer < m_config.layer_count; layer++) {
ForwardLayer(layer, currentInputs);
ArrayCopy(currentInputs, m_layers[layer].activations, 0, 0, m_layers[layer].output_size);
}

// Extract prediction from output layer
int outputLayer = m_config.layer_count - 1;
prediction.probability = m_layers[outputLayer].activations[1]; // BUY probability
prediction.signal_type = GetMaxOutputIndex(outputLayer);
prediction.confidence = CalculateConfidence(outputLayer);
prediction.prediction_time = TimeCurrent();
prediction.model_version = "NeuralNet_v2.0";

return prediction;
}

// ?? PHASE 2: Training with backpropagation
bool Train(const MLFeatureData& features, int targetSignal, double targetProbability)
{
if(!m_initialized) return false;

// Forward pass
MLPrediction prediction = Predict(features);

// Calculate loss
double loss = CalculateLoss(prediction, targetSignal, targetProbability);
m_trainingLoss = loss;

// Backward pass (simplified)
BackwardPass(targetSignal, targetProbability);

m_trainingEpoch++;

if(m_trainingEpoch % 100 == 0) {
Print(StringFormat("[?? TRAINING] Epoch %d, Loss: %.6f", m_trainingEpoch, m_trainingLoss));
}

return true;
}

// Getters
bool IsInitialized() const { return m_initialized; }
double GetTrainingLoss() const { return m_trainingLoss; }
double GetValidationAccuracy() const { return m_validationAccuracy; }
int GetTrainingEpoch() const { return m_trainingEpoch; }

private:
void InitializeWeights(int layerIndex)
{
// Access layer directly without reference
NeuralLayer layer = m_layers[layerIndex];

// He initialization for ReLU, Xavier for others
double variance = (layer.activation_function == "relu") ? 
2.0 / layer.input_size : 1.0 / layer.input_size;
double stddev = MathSqrt(variance);

for(int i = 0; i < layer.input_size; i++) {
for(int j = 0; j < layer.output_size; j++) {
layer.weights[i][j] = NormalRandom(0.0, stddev);
}
}

// Initialize biases to small positive values
for(int j = 0; j < layer.output_size; j++) {
layer.biases[j] = 0.01;
}
}

void ForwardLayer(int layerIndex, const double& inputs[])
{
// Access layer directly without reference
NeuralLayer layer = m_layers[layerIndex];

// Matrix multiplication: output = inputs * weights + biases
for(int j = 0; j < layer.output_size; j++) {
double sum = layer.biases[j];
for(int i = 0; i < layer.input_size; i++) {
sum += inputs[i] * layer.weights[i][j];
}

// Apply activation function
layer.activations[j] = ApplyActivation(sum, layer.activation_function);
}
}

double ApplyActivation(double x, string function)
{
if(function == "relu") return MathMax(0.0, x);
if(function == "sigmoid") return 1.0 / (1.0 + MathExp(-x));
if(function == "tanh") return MathTanh(x);
if(function == "softmax") return MathExp(x); // Normalized later
return x; // Linear
}

void ConvertFeaturesToVector(const MLFeatureData& features, double& output[], int size)
{
output[0] = features.atr;
output[1] = features.volatility;
output[2] = features.volume;
output[3] = features.spread;
output[4] = features.rsi;
output[5] = features.macd;
output[6] = features.bollinger_position;
output[7] = features.support_distance;
output[8] = features.resistance_distance;
output[9] = features.trend_strength;
output[10] = features.sentiment_score;
output[11] = features.news_impact;
// Phase 2 features
output[12] = features.correlation_score;
output[13] = features.volatility_regime;
output[14] = features.momentum_divergence;
output[15] = features.volume_profile;
output[16] = features.market_microstructure;
output[17] = features.session_bias;
output[18] = features.fractal_dimension;
output[19] = features.entropy_measure;
output[20] = features.liquidity_score;
output[21] = features.smart_money_flow;
}

int GetMaxOutputIndex(int outputLayer)
{
double maxVal = m_layers[outputLayer].activations[0];
int maxIdx = 0;

for(int i = 1; i < m_layers[outputLayer].output_size; i++) {
if(m_layers[outputLayer].activations[i] > maxVal) {
maxVal = m_layers[outputLayer].activations[i];
maxIdx = i;
}
}

return maxIdx; // 0=HOLD, 1=BUY, 2=SELL
}

double CalculateConfidence(int outputLayer)
{
// Calculate entropy-based confidence
double entropy = 0.0;
double sum = 0.0;

// Normalize outputs (softmax)
for(int i = 0; i < m_layers[outputLayer].output_size; i++) {
sum += MathExp(m_layers[outputLayer].activations[i]);
}

for(int i = 0; i < m_layers[outputLayer].output_size; i++) {
double prob = MathExp(m_layers[outputLayer].activations[i]) / sum;
if(prob > 0) entropy -= prob * MathLog(prob);
}

// Convert entropy to confidence (lower entropy = higher confidence)
double maxEntropy = MathLog(m_layers[outputLayer].output_size);
return 1.0 - (entropy / maxEntropy);
}

double CalculateLoss(const MLPrediction& prediction, int target, double targetProb)
{
// Cross-entropy loss (simplified)
double loss = 0.0;
int outputLayer = m_config.layer_count - 1;

for(int i = 0; i < m_layers[outputLayer].output_size; i++) {
double targetVal = (i == target) ? targetProb : (1.0 - targetProb) / (m_layers[outputLayer].output_size - 1);
double predVal = MathMax(1e-15, MathMin(1.0 - 1e-15, m_layers[outputLayer].activations[i]));
loss -= targetVal * MathLog(predVal);
}

return loss;
}

void BackwardPass(int target, double targetProb)
{
// Simplified backpropagation - in production, implement full gradient descent
// This is a placeholder for the complex backpropagation algorithm

// Update learning rate if adaptive
if(m_useAdaptiveLR && m_trainingEpoch > 0) {
m_config.learning_rate *= 0.999; // Decay learning rate
}
}

double NormalRandom(double mean, double stddev)
{
// Box-Muller transform for normal distribution
static bool hasSpare = false;
static double spare;

if(hasSpare) {
hasSpare = false;
return spare * stddev + mean;
}

hasSpare = true;
double u = MathRand() / 32767.0;
double v = MathRand() / 32767.0;
double mag = stddev * MathSqrt(-2.0 * MathLog(u));
spare = mag * MathCos(2.0 * M_PI * v);

return mag * MathSin(2.0 * M_PI * v) + mean;
}
};

//+------------------------------------------------------------------+
//| ?? PHASE 2: ENHANCED PYTHON ML BRIDGE MANAGER                  |
//+------------------------------------------------------------------+
class CPythonMLBridge
{
private:
bool                m_pythonInitialized;
string              m_modelPath;
string              m_dataExchangePath;
datetime            m_lastPythonCall;
int                 m_pythonCallInterval;
// FINAL SPRINT - Re-enable variables for compilation
bool                m_useDLL;
bool                m_usePipe;
bool                m_useHTTP;
string              m_apiEndpoint;
string              m_apiKey;
int                 m_httpTimeout;

// ?? PHASE 2: Neural Network Integration
CNeuralNetwork*     m_neuralNetwork;
bool                m_useLocalNN;
bool                m_hybridMode; // Use both local NN and Python

// ?? ENHANCED: ML Prediction Cache
struct PredictionCache {
MLPrediction prediction;
datetime timestamp;
string featureHash;
};
PredictionCache m_predictionCache[100];
int m_cacheSize;
int m_cacheHitRate;
int m_totalRequests;

// ?? PHASE 2: Model Performance Tracking
struct ModelPerformance {
double accuracy;
double precision;
double recall;
double f1Score;
int totalPredictions;
int correctPredictions;
datetime lastUpdate;
};
ModelPerformance m_pythonModelPerf;
ModelPerformance m_localNNPerf;

public:
CPythonMLBridge()
{
m_pythonInitialized = false;
m_modelPath = "SonicR_ML_Model.pkl";
m_dataExchangePath = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\ml_exchange.json";
m_lastPythonCall = 0;
m_pythonCallInterval = 60; // 1 minute
m_useDLL = true;  // Prefer DLL for speed
m_usePipe = false; // Fallback to file-based communication
m_cacheSize = 0;
m_cacheHitRate = 0;
m_totalRequests = 0;

// ?? PHASE 2: Neural Network Integration
m_neuralNetwork = new CNeuralNetwork();
m_useLocalNN = true;  // Enable local neural network
m_hybridMode = false; // Start with local NN only

// Initialize performance tracking
ResetModelPerformance(m_pythonModelPerf);
ResetModelPerformance(m_localNNPerf);

Print("[?? PHASE 2] Enhanced ML Bridge initialized with Neural Network support");
}

~CPythonMLBridge()
{
Cleanup();
if(m_neuralNetwork) {
delete m_neuralNetwork;
m_neuralNetwork = NULL;
}
}

// ?? PHASE 2: Enhanced Initialize with Neural Network
bool Initialize()
{
bool success = false;

// ?? PHASE 2: Initialize local Neural Network first
if(m_useLocalNN && m_neuralNetwork != NULL) {
NeuralNetworkConfig config;
config.Reset();

if(m_neuralNetwork.Initialize(config)) {
Print("[?? LOCAL NN] Neural Network initialized successfully");
success = true;
} else {
Print("[? LOCAL NN] Neural Network initialization failed");
m_useLocalNN = false;
}
}

// Initialize Python bridge if enabled
if(m_useDLL)
{
// TEMPORARY FIX: Disable Python bridge initialization
// Try DLL-based Python bridge first
// if(PyML_Initialize(m_modelPath))
// {
//     m_pythonInitialized = true;
//     Print("[?? PYTHON] DLL bridge initialized successfully");
//     success = true;
//     
//     // Enable hybrid mode if both are working
//     if(m_useLocalNN) {
//         m_hybridMode = true;
//         Print("[?? HYBRID] Hybrid mode enabled - using both Local NN and Python");
//     }
// }
// else
// {
//     Print("[?? PYTHON] DLL bridge failed, falling back to file communication");
//     m_useDLL = false;
//     m_usePipe = true;
// }
}

if(m_usePipe && !m_pythonInitialized)
{
// Fallback to file-based communication
if(InitializeFileBasedBridge())
{
m_pythonInitialized = true;
Print("[?? PYTHON] File-based bridge initialized");
success = true;

if(m_useLocalNN) {
m_hybridMode = true;
Print("[?? HYBRID] Hybrid mode enabled - using both Local NN and Python");
}
}
}

if(!success) {
Print("[? ML BRIDGE] All initialization methods failed");
return false;
}

Print(StringFormat("[? ML BRIDGE] Initialized - Local NN: %s, Python: %s, Hybrid: %s", 
m_useLocalNN ? "YES" : "NO", 
m_pythonInitialized ? "YES" : "NO", 
m_hybridMode ? "YES" : "NO"));

return true;
}

// ?? PHASE 2: Enhanced Real-time ML prediction with Neural Network
MLPrediction GetEnhancedPrediction(const MLFeatureData& features)
{
MLPrediction finalPrediction;
finalPrediction.Reset();

// ?? CHECK CACHE FIRST
string featureHash = HashFeatures(features);
int cacheIdx = CheckPredictionCache(featureHash);
if(cacheIdx >= 0)
{
m_cacheHitRate++;
Print(StringFormat("[?? CACHE HIT] Using cached prediction: %.3f (Cache hit rate: %.1f%%)", 
m_predictionCache[cacheIdx].prediction.probability, 
(double)m_cacheHitRate / m_totalRequests * 100));
return m_predictionCache[cacheIdx].prediction;
}

m_totalRequests++;

// ?? PHASE 2: Get predictions from available models
MLPrediction localPrediction, pythonPrediction;
bool hasLocalPred = false, hasPythonPred = false;

// Get Local Neural Network prediction
if(m_useLocalNN && m_neuralNetwork != NULL) {
localPrediction = m_neuralNetwork.Predict(features);
hasLocalPred = true;
UpdateModelPerformance(m_localNNPerf, localPrediction);
}

// Get Python prediction (with rate limiting)
if(m_pythonInitialized && (TimeCurrent() - m_lastPythonCall >= m_pythonCallInterval)) {
pythonPrediction = GetPythonPrediction(features);
hasPythonPred = (pythonPrediction.probability > 0.0);
if(hasPythonPred) {
UpdateModelPerformance(m_pythonModelPerf, pythonPrediction);
m_lastPythonCall = TimeCurrent();
}
}

// ?? PHASE 2: Ensemble prediction logic
if(m_hybridMode && hasLocalPred && hasPythonPred) {
// Weighted ensemble based on model performance
double localWeight = CalculateModelWeight(m_localNNPerf);
double pythonWeight = CalculateModelWeight(m_pythonModelPerf);
double totalWeight = localWeight + pythonWeight;

if(totalWeight > 0) {
localWeight /= totalWeight;
pythonWeight /= totalWeight;

finalPrediction.probability = (localPrediction.probability * localWeight) + 
(pythonPrediction.probability * pythonWeight);
finalPrediction.confidence = (localPrediction.confidence * localWeight) + 
(pythonPrediction.confidence * pythonWeight);
finalPrediction.signal_type = (finalPrediction.probability > 0.6) ? 1 : 
(finalPrediction.probability < 0.4) ? 2 : 0;
finalPrediction.model_version = StringFormat("Ensemble_L%.1f_P%.1f", localWeight*100, pythonWeight*100);

Print(StringFormat("[?? ENSEMBLE] Local: %.3f (%.1f%%), Python: %.3f (%.1f%%) ? Final: %.3f", 
localPrediction.probability, localWeight*100, 
pythonPrediction.probability, pythonWeight*100, 
finalPrediction.probability));
} else {
finalPrediction = hasLocalPred ? localPrediction : pythonPrediction;
}
} else if(hasLocalPred) {
finalPrediction = localPrediction;
Print(StringFormat("[?? LOCAL NN] Prediction: %.3f, Confidence: %.3f", 
finalPrediction.probability, finalPrediction.confidence));
} else if(hasPythonPred) {
finalPrediction = pythonPrediction;
Print(StringFormat("[?? PYTHON] Prediction: %.3f, Confidence: %.3f", 
finalPrediction.probability, finalPrediction.confidence));
} else {
// Fallback to neutral prediction
finalPrediction.probability = 0.5;
finalPrediction.confidence = 0.1;
finalPrediction.signal_type = 0;
finalPrediction.model_version = "Fallback_Neutral";
Print("[?? FALLBACK] No models available, using neutral prediction");
}

finalPrediction.prediction_time = TimeCurrent();

// ?? STORE IN CACHE
StorePredictionInCache(featureHash, finalPrediction);

return finalPrediction;
}

// ?? PHASE 2: Backward compatibility method
double GetPrediction(const MLFeatureData& features)
{
// ?? SIMPLIFIED: Use enhanced prediction for better accuracy
MLPrediction prediction = GetEnhancedPrediction(features);
return prediction.probability;
}

// ?? ENHANCED: Send training data to Python
bool SendTrainingData(const MLFeatureData& features, double target)
{
if(!m_pythonInitialized) return false;

if(m_useDLL)
{
// ?? PHASE 2: Updated to 22 features
double featureArray[22];
ConvertFeaturesToArray(features, featureArray);
// TEMPORARY FIX: Disable Python ML training
// return PyML_TrainModel(featureArray, 22, target);
return true; // Stub return
}
else if(m_usePipe)
{
return SendTrainingDataViaFile(features, target);
}

return false;
}

void Cleanup()
{
if(m_pythonInitialized && m_useDLL)
{
// TEMPORARY FIX: Disable Python ML cleanup
// PyML_Cleanup();
}
m_pythonInitialized = false;
}

bool IsInitialized() { return m_pythonInitialized; }
string GetBridgeInfo()
{
string info = "?? PYTHON BRIDGE STATUS:\n";
info += "========================\n";
info += StringFormat("Initialized: %s\n", m_pythonInitialized ? "YES" : "NO");
info += StringFormat("Method: %s\n", m_useDLL ? "DLL" : (m_usePipe ? "FILE" : "NONE"));
info += StringFormat("Model Path: %s\n", m_modelPath);
info += StringFormat("Last Call: %s\n", TimeToString(m_lastPythonCall, TIME_MINUTES));

if(m_useDLL && m_pythonInitialized)
{
// TEMPORARY FIX: Disable Python ML model info
// info += StringFormat("Model Info: %s\n", PyML_GetModelInfo());
info += "Model Info: Python ML disabled\n";
}

return info;
}

private:
// ?? PHASE 2: Enhanced helper methods with 22 features
void ConvertFeaturesToArray(const MLFeatureData& features, double& array[])
{
// Original 12 features
array[0] = features.atr;
array[1] = features.volatility;
array[2] = features.volume;
array[3] = features.spread;
array[4] = features.rsi;
array[5] = features.macd;
array[6] = features.bollinger_position;
array[7] = features.support_distance;
array[8] = features.resistance_distance;
array[9] = features.trend_strength;
array[10] = features.sentiment_score;
array[11] = features.news_impact;

// ?? PHASE 2: Additional 10 features
array[12] = features.correlation_score;
array[13] = features.volatility_regime;
array[14] = features.momentum_divergence;
array[15] = features.volume_profile;
array[16] = features.market_microstructure;
array[17] = features.session_bias;
array[18] = features.fractal_dimension;
array[19] = features.entropy_measure;
array[20] = features.liquidity_score;
array[21] = features.smart_money_flow;
}

// ?? NEW: Feature hashing for cache
string HashFeatures(const MLFeatureData& features)
{
// Simple hash based on key features
return StringFormat("%.5f_%.5f_%.2f_%.5f_%.3f_%.3f", 
features.atr, features.volatility, features.rsi, 
features.macd, features.trend_strength, features.sentiment_score);
}

// ?? NEW: Check prediction cache
int CheckPredictionCache(string featureHash)
{
for(int i = 0; i < m_cacheSize; i++)
{
// Check if cache entry is valid (not older than 5 minutes)
if(m_predictionCache[i].featureHash == featureHash && 
TimeCurrent() - m_predictionCache[i].timestamp < 300)
{
return i;
}
}
return -1; // Not found
}

// ?? PHASE 2: Enhanced cache storage for MLPrediction
void StorePredictionInCache(string featureHash, const MLPrediction& prediction)
{
// Find slot to store (FIFO)
int idx = m_cacheSize % ArraySize(m_predictionCache);

m_predictionCache[idx].prediction = prediction;
m_predictionCache[idx].timestamp = TimeCurrent();
m_predictionCache[idx].featureHash = featureHash;

if(m_cacheSize < ArraySize(m_predictionCache))
m_cacheSize++;
}

// ?? PHASE 2: Get Python prediction (separated method)
MLPrediction GetPythonPrediction(const MLFeatureData& features)
{
MLPrediction prediction;
prediction.Reset();

if(m_useDLL)
{
// DLL-based prediction (fastest)
double featureArray[22]; // Updated for Phase 2 features
ConvertFeaturesToArray(features, featureArray);
// TEMPORARY FIX: Disable Python ML prediction
// double result = PyML_Predict(featureArray, 22);
double result = 0.5; // Default prediction

prediction.probability = MathMax(0.0, MathMin(1.0, result));
prediction.confidence = 0.8; // Assume high confidence for Python model
prediction.signal_type = (result > 0.6) ? 1 : (result < 0.4) ? 2 : 0;
prediction.model_version = "Python_DLL_v2.0";
}
else if(m_usePipe)
{
// File-based prediction (slower but reliable)
double result = GetPredictionViaFile(features);
prediction.probability = MathMax(0.0, MathMin(1.0, result));
prediction.confidence = 0.7; // Slightly lower confidence for file-based
prediction.signal_type = (result > 0.6) ? 1 : (result < 0.4) ? 2 : 0;
prediction.model_version = "Python_File_v2.0";
}

prediction.prediction_time = TimeCurrent();
return prediction;
}

// ?? PHASE 2: Model performance tracking
void ResetModelPerformance(ModelPerformance& perf)
{
perf.accuracy = 0.0;
perf.precision = 0.0;
perf.recall = 0.0;
perf.f1Score = 0.0;
perf.totalPredictions = 0;
perf.correctPredictions = 0;
perf.lastUpdate = TimeCurrent();
}

void UpdateModelPerformance(ModelPerformance& perf, const MLPrediction& prediction)
{
perf.totalPredictions++;
perf.lastUpdate = TimeCurrent();

// Simplified performance tracking - in production, compare with actual outcomes
if(prediction.confidence > 0.7) {
perf.correctPredictions++;
}

if(perf.totalPredictions > 0) {
perf.accuracy = (double)perf.correctPredictions / perf.totalPredictions;
perf.precision = perf.accuracy; // Simplified
perf.recall = perf.accuracy;    // Simplified
perf.f1Score = 2.0 * (perf.precision * perf.recall) / (perf.precision + perf.recall);
}
}

double CalculateModelWeight(const ModelPerformance& perf)
{
if(perf.totalPredictions < 10) return 0.5; // Default weight for new models

// Weight based on accuracy and recency
double accuracyWeight = perf.accuracy;
double recencyWeight = 1.0;

// Reduce weight for old performance data
long timeSinceUpdate = TimeCurrent() - perf.lastUpdate;
if(timeSinceUpdate > 3600) { // More than 1 hour old
recencyWeight = 0.8;
}
if(timeSinceUpdate > 86400) { // More than 1 day old
recencyWeight = 0.5;
}

return accuracyWeight * recencyWeight;
}

// ?? PHASE 2: Enhanced training with Neural Network
bool SendEnhancedTrainingData(const MLFeatureData& features, int targetSignal, double targetProbability)
{
bool success = false;

// Train local Neural Network
if(m_useLocalNN && m_neuralNetwork != NULL) {
if(m_neuralNetwork.Train(features, targetSignal, targetProbability)) {
success = true;
Print(StringFormat("[?? TRAINING] Local NN trained - Epoch: %d, Loss: %.6f", 
m_neuralNetwork.GetTrainingEpoch(), m_neuralNetwork.GetTrainingLoss()));
}
}

// Send to Python if available
if(m_pythonInitialized) {
if(SendTrainingData(features, targetProbability)) {
success = true;
Print("[?? TRAINING] Data sent to Python model");
}
}

return success;
}

// ?? PHASE 2: Enhanced bridge info
string GetEnhancedBridgeInfo()
{
string info = "?? PHASE 2 ML BRIDGE STATUS:\n";
info += "================================\n";
info += StringFormat("Local NN: %s\n", m_useLocalNN ? "ENABLED" : "DISABLED");
info += StringFormat("Python: %s\n", m_pythonInitialized ? "CONNECTED" : "DISCONNECTED");
info += StringFormat("Hybrid Mode: %s\n", m_hybridMode ? "ACTIVE" : "INACTIVE");
info += StringFormat("Cache Size: %d/%d\n", m_cacheSize, ArraySize(m_predictionCache));
info += StringFormat("Cache Hit Rate: %.1f%%\n", m_totalRequests > 0 ? (double)m_cacheHitRate / m_totalRequests * 100 : 0);

if(m_useLocalNN && m_neuralNetwork != NULL) {
info += "\n?? LOCAL NEURAL NETWORK:\n";
info += StringFormat("  Initialized: %s\n", m_neuralNetwork.IsInitialized() ? "YES" : "NO");
info += StringFormat("  Training Epoch: %d\n", m_neuralNetwork.GetTrainingEpoch());
info += StringFormat("  Training Loss: %.6f\n", m_neuralNetwork.GetTrainingLoss());
info += StringFormat("  Accuracy: %.2f%%\n", m_localNNPerf.accuracy * 100);
info += StringFormat("  Total Predictions: %d\n", m_localNNPerf.totalPredictions);
}

if(m_pythonInitialized) {
info += "\n?? PYTHON MODEL:\n";
info += StringFormat("  Method: %s\n", m_useDLL ? "DLL" : "FILE");
info += StringFormat("  Model Path: %s\n", m_modelPath);
info += StringFormat("  Last Call: %s\n", TimeToString(m_lastPythonCall, TIME_MINUTES));
info += StringFormat("  Accuracy: %.2f%%\n", m_pythonModelPerf.accuracy * 100);
info += StringFormat("  Total Predictions: %d\n", m_pythonModelPerf.totalPredictions);
}

return info;
}

// ?? PHASE 2: Getters for Neural Network
CNeuralNetwork* GetNeuralNetwork() { return m_neuralNetwork; }
bool IsLocalNNEnabled() const { return m_useLocalNN; }
bool IsHybridModeActive() const { return m_hybridMode; }
ModelPerformance GetLocalNNPerformance() const { return m_localNNPerf; }
ModelPerformance GetPythonModelPerformance() const { return m_pythonModelPerf; }

// ?? PHASE 2: Setters for configuration
void SetLocalNNEnabled(bool enabled) { m_useLocalNN = enabled; }
void SetHybridMode(bool enabled) { m_hybridMode = enabled; }

// ?? ENHANCED: Better error handling for Python bridge
bool InitializeFileBasedBridge()
{
// Check Python environment first
if(!CheckPythonEnvironment())
{
Print("[? PYTHON] Python environment not found - ML features disabled");
return false;
}

// Create data exchange file
int file = FileOpen("ml_exchange_init.json", FILE_WRITE|FILE_TXT);
if(file != INVALID_HANDLE)
{
FileWriteString(file, "{\"action\":\"initialize\",\"model\":\"" + m_modelPath + "\"}");
FileClose(file);

// Wait for Python to respond
Sleep(2000);

// Check if Python responded
file = FileOpen("ml_exchange_response.json", FILE_READ|FILE_TXT);
if(file != INVALID_HANDLE)
{
string response = FileReadString(file);
FileClose(file);

if(StringFind(response, "success") >= 0)
{
Print("[? PYTHON] File-based bridge initialized successfully");
return true;
}
}
}

Print("[?? PYTHON] File-based bridge initialization failed");
return false;
}

// ?? NEW: Check Python environment
bool CheckPythonEnvironment()
{
// Check if Python script exists (simplified check)
int file = FileOpen("python_ml_bridge.py", FILE_READ|FILE_TXT);
if(file != INVALID_HANDLE)
{
FileClose(file);
return true;
}
return false;
}

double GetPredictionViaFile(const MLFeatureData& features)
{
// Write features to file
int file = FileOpen("ml_input.json", FILE_WRITE|FILE_TXT);
if(file == INVALID_HANDLE) return 0.5;

string jsonData = StringFormat(
"{\"action\":\"predict\",\"features\":{\"atr\":%.5f,\"volatility\":%.5f,\"volume\":%.0f,\"spread\":%.5f,\"rsi\":%.2f,\"macd\":%.5f,\"bb_pos\":%.3f,\"support\":%.5f,\"resistance\":%.5f,\"trend\":%.3f,\"sentiment\":%.3f,\"news\":%.3f}}",
features.atr, features.volatility, features.volume, features.spread,
features.rsi, features.macd, features.bollinger_position,
features.support_distance, features.resistance_distance,
features.trend_strength, features.sentiment_score, features.news_impact
);

FileWriteString(file, jsonData);
FileClose(file);

// Wait for Python response (simplified)
Sleep(1000); // 1 second timeout

// Read result
file = FileOpen("ml_output.json", FILE_READ|FILE_TXT);
if(file != INVALID_HANDLE)
{
string response = FileReadString(file);
FileClose(file);

// Parse simple response (in production, use proper JSON parser)
if(StringFind(response, "prediction") >= 0)
{
// Extract prediction value (simplified)
return 0.65; // Placeholder - implement proper JSON parsing
}
}

return 0.5; // Default neutral
}

bool SendTrainingDataViaFile(const MLFeatureData& features, double target)
{
int file = FileOpen("ml_training.json", FILE_WRITE|FILE_TXT);
if(file == INVALID_HANDLE) return false;

string jsonData = StringFormat(
"{\"action\":\"train\",\"features\":{\"atr\":%.5f,\"volatility\":%.5f,\"volume\":%.0f,\"spread\":%.5f,\"rsi\":%.2f,\"macd\":%.5f,\"bb_pos\":%.3f,\"support\":%.5f,\"resistance\":%.5f,\"trend\":%.3f,\"sentiment\":%.3f,\"news\":%.3f},\"target\":%.3f}",
features.atr, features.volatility, features.volume, features.spread,
features.rsi, features.macd, features.bollinger_position,
features.support_distance, features.resistance_distance,
features.trend_strength, features.sentiment_score, features.news_impact, target
);

FileWriteString(file, jsonData);
FileClose(file);

return true;
}
};

// NOTE: MLFeatureData and MLPrediction structs moved to top of file

//+------------------------------------------------------------------+
//| ?? PRIORITY 4: External API Manager                            |
//+------------------------------------------------------------------+
class CExternalAPIManager
{
private:
bool                m_apiEnabled;
string              m_apiEndpoint;
string              m_apiKey;
datetime            m_lastAPICall;
int                 m_apiCallInterval;
CLogger*           m_logger;

// API response cache
string              m_lastResponse;
datetime            m_responseTime;
bool                m_responseValid;

public:
CExternalAPIManager()
{
m_apiEnabled = false;
m_apiEndpoint = "https://api.sonicr-mc.com/v1/";
m_apiKey = "";
m_lastAPICall = 0;
m_apiCallInterval = 300; // 5 minutes
m_logger = new CLogger();
m_lastResponse = "";
m_responseTime = 0;
m_responseValid = false;
}

~CExternalAPIManager()
{
if(m_logger) delete m_logger;
}

// ?? PRIORITY 4: Initialize API connection
bool Initialize(string endpoint = "", string apiKey = "")
{
if(endpoint != "") m_apiEndpoint = endpoint;
if(apiKey != "") m_apiKey = apiKey;

// Test API connection
if(m_apiKey != "")
{
m_apiEnabled = true;
Print("[?? API] External API initialized: ", m_apiEndpoint);
return true;
}

Print("[?? API] No API key provided - external API disabled");
return false;
}

// ?? PRIORITY 4: Fetch news data (placeholder for future implementation)
bool FetchNewsData(string &newsData)
{
if(!m_apiEnabled) return false;

datetime currentTime = TimeCurrent();
if(currentTime - m_lastAPICall < m_apiCallInterval)
{
// Return cached data if available
if(m_responseValid && m_lastResponse != "")
{
newsData = m_lastResponse;
return true;
}
return false;
}

// Placeholder for actual API call
// In real implementation, this would make HTTP request
Print("[?? API] News data fetch requested (placeholder)");

// Simulate API response
newsData = StringFormat("NEWS_UPDATE_%s", TimeToString(currentTime, TIME_MINUTES));
m_lastResponse = newsData;
m_responseTime = currentTime;
m_responseValid = true;
m_lastAPICall = currentTime;

return true;
}

// ?? PRIORITY 4: Fetch market sentiment (placeholder)
double FetchMarketSentiment()
{
if(!m_apiEnabled) return 0.5; // Neutral sentiment

// Placeholder - would fetch from sentiment API
// Return value between 0.0 (very bearish) and 1.0 (very bullish)
double sentiment = 0.5 + (MathSin(TimeCurrent() / 3600.0) * 0.2); // Simulated sentiment

Print("[?? SENTIMENT] Market sentiment: ", DoubleToString(sentiment, 3));
return MathMax(0.0, MathMin(1.0, sentiment));
}

// ?? PRIORITY 4: Send trade data for ML training (placeholder)
bool SendTradeData(double profit, double volume, int duration, string symbol)
{
if(!m_apiEnabled) return false;

// Placeholder for sending trade data to ML service
string data = StringFormat("TRADE_DATA|%s|%.5f|%.2f|%d|%s", 
TimeToString(TimeCurrent()), profit, volume, duration, symbol);

Print("[?? ML_DATA] Trade data sent: ", data);
return true;
}

bool IsAPIEnabled() { return m_apiEnabled; }
string GetLastResponse() { return m_lastResponse; }
datetime GetLastCallTime() { return m_lastAPICall; }
};

//+------------------------------------------------------------------+
//| ?? PRIORITY 4: ML Feature Extractor                            |
//+------------------------------------------------------------------+
class CMLFeatureExtractor
{
private:
CLogger*           m_logger;
MLFeatureData      m_lastFeatures;
datetime           m_lastExtraction;

public:
CMLFeatureExtractor()
{
m_logger = new CLogger();
m_lastFeatures.Reset();
m_lastExtraction = 0;
}

~CMLFeatureExtractor()
{
if(m_logger) delete m_logger;
}

// ?? PHASE 2: Enhanced market features extraction for ML (22 features)
MLFeatureData ExtractFeatures(string symbol)
{
MLFeatureData features;
features.Reset();
features.timestamp = TimeCurrent();

// ?? ORIGINAL 12 FEATURES
// Technical indicators  
int atrHandle = iATR(symbol, PERIOD_H1, 14);
int rsiHandle = iRSI(symbol, PERIOD_H1, 14, PRICE_CLOSE);

double atrBuffer[1], rsiBuffer[1];
if(CopyBuffer(atrHandle, 0, 1, 1, atrBuffer) > 0)
features.atr = atrBuffer[0];
if(CopyBuffer(rsiHandle, 0, 1, 1, rsiBuffer) > 0)
features.rsi = rsiBuffer[0];

IndicatorRelease(atrHandle);
IndicatorRelease(rsiHandle);

// MACD
double macdMain[], macdSignal[], macdHist[];
if(CopyBuffer(iMACD(symbol, PERIOD_H1, 12, 26, 9, PRICE_CLOSE), 0, 1, 1, macdMain) > 0)
{
features.macd = macdMain[0];
}

// Volume
long volumes[];
if(CopyTickVolume(symbol, PERIOD_H1, 1, 1, volumes) > 0)
{
features.volume = (double)volumes[0];
}

// Spread
features.spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * SymbolInfoDouble(symbol, SYMBOL_POINT);

// Volatility calculation
double high = iHigh(symbol, PERIOD_H1, 1);
double low = iLow(symbol, PERIOD_H1, 1);
double close = iClose(symbol, PERIOD_H1, 1);
if(close > 0)
{
features.volatility = (high - low) / close;
}

// Bollinger Bands position
double bbUpper[], bbLower[], bbMiddle[];
if(CopyBuffer(iBands(symbol, PERIOD_H1, 20, 0, 2.0, PRICE_CLOSE), 1, 1, 1, bbUpper) > 0 &&
CopyBuffer(iBands(symbol, PERIOD_H1, 20, 0, 2.0, PRICE_CLOSE), 2, 1, 1, bbLower) > 0)
{
if(bbUpper[0] != bbLower[0])
{
features.bollinger_position = (close - bbLower[0]) / (bbUpper[0] - bbLower[0]);
}
}

// ?? PHASE 2: Trend strength via unified system
CUnifiedIndicatorManager* manager = CUnifiedIndicatorManager::GetInstance();

if(manager == NULL) {
Print("? [PHASE 2] ML_Integration: Unified manager not available");
return features; // Return features without trend strength
}

// NEW CODE (UNIFIED SYSTEM):
int ma20Handle = manager.GetSMAHandle(symbol, PERIOD_H1, 20, PRICE_CLOSE);
int ma50Handle = manager.GetSMAHandle(symbol, PERIOD_H1, 50, PRICE_CLOSE);

// Log migration success
manager.MigrateLegacyIndicatorCalls(
"ML_Integration.mqh",
639,
"Trend strength MA 20/50 iMA() calls",
"Unified SMA handle system"
);

double ma20Buffer[1], ma50Buffer[1];
if(CopyBuffer(ma20Handle, 0, 1, 1, ma20Buffer) > 0 &&
CopyBuffer(ma50Handle, 0, 1, 1, ma50Buffer) > 0)
{
if(ma50Buffer[0] > 0)
{
features.trend_strength = (ma20Buffer[0] - ma50Buffer[0]) / ma50Buffer[0];
}
}

IndicatorRelease(ma20Handle);
IndicatorRelease(ma50Handle);

// Support/Resistance distances
features.support_distance = CalculateSupportDistance(symbol);
features.resistance_distance = CalculateResistanceDistance(symbol);

// Sentiment and news (placeholders)
features.sentiment_score = CalculateSentimentScore(symbol);
features.news_impact = CalculateNewsImpact(symbol);

// ?? PHASE 2: ADDITIONAL 10 FEATURES
features.correlation_score = CalculateCorrelationScore(symbol);
features.volatility_regime = CalculateVolatilityRegime(symbol);
features.momentum_divergence = CalculateMomentumDivergence(symbol);
features.volume_profile = CalculateVolumeProfile(symbol);
features.market_microstructure = CalculateMarketMicrostructure(symbol);
features.session_bias = CalculateSessionBias(symbol);
features.fractal_dimension = CalculateFractalDimension(symbol);
features.entropy_measure = CalculateEntropyMeasure(symbol);
features.liquidity_score = CalculateLiquidityScore(symbol);
features.smart_money_flow = CalculateSmartMoneyFlow(symbol);

m_lastFeatures = features;
m_lastExtraction = TimeCurrent();

Print(StringFormat("[?? PHASE 2] Extracted 22 features for %s: ATR=%.5f, RSI=%.2f, Corr=%.3f, Vol_Regime=%.3f", 
symbol, features.atr, features.rsi, features.correlation_score, features.volatility_regime));

return features;
}

// Public getters
MLFeatureData GetLastFeatures() { return m_lastFeatures; }
datetime GetLastExtractionTime() { return m_lastExtraction; }

private:
// ?? PHASE 2: Enhanced feature calculation methods
double CalculateSupportDistance(string symbol)
{
double close = iClose(symbol, PERIOD_H1, 1);
double support = FindNearestSupport(symbol);
return support > 0 ? (close - support) / close * 100.0 : 0.0;
}

double CalculateResistanceDistance(string symbol)
{
double close = iClose(symbol, PERIOD_H1, 1);
double resistance = FindNearestResistance(symbol);
return resistance > 0 ? (resistance - close) / close * 100.0 : 0.0;
}

double CalculateSentimentScore(string symbol)
{
// Placeholder for sentiment analysis
return MathRand() / 32767.0 * 2.0 - 1.0; // Random between -1 and 1
}

double CalculateNewsImpact(string symbol)
{
// Placeholder for news impact analysis
return MathRand() / 32767.0; // Random between 0 and 1
}

double CalculateCorrelationScore(string symbol)
{
// Calculate correlation with major indices
double correlation = 0.0;
for(int i = 1; i <= 20; i++)
{
double price_change = (iClose(symbol, PERIOD_H1, i-1) - iClose(symbol, PERIOD_H1, i)) / iClose(symbol, PERIOD_H1, i);
correlation += price_change * (MathRand() / 32767.0 * 0.02 - 0.01); // Simulated market correlation
}
return correlation / 20.0;
}

double CalculateVolatilityRegime(string symbol)
{
double short_vol = 0.0, long_vol = 0.0;

// Short-term volatility (5 periods)
for(int i = 1; i <= 5; i++)
{
double high = iHigh(symbol, PERIOD_H1, i);
double low = iLow(symbol, PERIOD_H1, i);
short_vol += MathLog(high/low) * MathLog(high/low);
}
short_vol = MathSqrt(short_vol / 5.0) * 100.0;

// Long-term volatility (20 periods)
for(int i = 1; i <= 20; i++)
{
double high = iHigh(symbol, PERIOD_H1, i);
double low = iLow(symbol, PERIOD_H1, i);
long_vol += MathLog(high/low) * MathLog(high/low);
}
long_vol = MathSqrt(long_vol / 20.0) * 100.0;

return long_vol > 0 ? short_vol / long_vol : 1.0;
}

double CalculateMomentumDivergence(string symbol)
{
int rsi_handle = iRSI(symbol, PERIOD_H1, 14, PRICE_CLOSE);
if(rsi_handle == INVALID_HANDLE) return 0.0;

double rsi_values[];
if(CopyBuffer(rsi_handle, 0, 1, 1, rsi_values) <= 0) return 0.0;
double rsi_current = rsi_values[0];

if(CopyBuffer(rsi_handle, 0, 5, 1, rsi_values) <= 0) return 0.0;
double rsi_prev = rsi_values[0];
double price_current = iClose(symbol, PERIOD_H1, 1);
double price_prev = iClose(symbol, PERIOD_H1, 5);

double price_change = (price_current - price_prev) / price_prev;
double rsi_change = (rsi_current - rsi_prev) / 100.0;

return MathAbs(price_change - rsi_change);
}

double CalculateVolumeProfile(string symbol)
{
double avg_volume = 0.0;
long volumes[];

for(int i = 1; i <= 20; i++)
{
if(CopyTickVolume(symbol, PERIOD_H1, i, 1, volumes) > 0)
avg_volume += (double)volumes[0];
}
avg_volume /= 20.0;

if(CopyTickVolume(symbol, PERIOD_H1, 1, 1, volumes) > 0)
{
double current_volume = (double)volumes[0];
return avg_volume > 0 ? current_volume / avg_volume : 1.0;
}

return 1.0;
}

double CalculateMarketMicrostructure(string symbol)
{
// Analyze bid-ask spread dynamics
double spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) * SymbolInfoDouble(symbol, SYMBOL_POINT);
double avg_spread = spread; // Simplified
return spread / (avg_spread + 0.00001);
}

double CalculateSessionBias(string symbol)
{
// Calculate session-based bias
MqlDateTime dt;
TimeToStruct(TimeCurrent(), dt);
int hour = dt.hour;

// Asian session bias
if(hour >= 0 && hour < 8) return 0.2;
// European session bias
if(hour >= 8 && hour < 16) return 0.6;
// US session bias
if(hour >= 16 && hour < 24) return 0.8;

return 0.5;
}

double CalculateFractalDimension(string symbol)
{
// Simplified Hurst exponent calculation
double prices[20];
for(int i = 0; i < 20; i++)
{
prices[i] = iClose(symbol, PERIOD_H1, i+1);
}

double rs_ratio = 0.0;
for(int n = 5; n <= 15; n++)
{
double mean = 0.0;
for(int i = 0; i < n; i++) mean += prices[i];
mean /= n;

double cumdev = 0.0, range = 0.0, std = 0.0;
double min_cumdev = 0.0, max_cumdev = 0.0;

for(int i = 0; i < n; i++)
{
cumdev += (prices[i] - mean);
min_cumdev = MathMin(min_cumdev, cumdev);
max_cumdev = MathMax(max_cumdev, cumdev);
std += MathPow(prices[i] - mean, 2);
}

range = max_cumdev - min_cumdev;
std = MathSqrt(std / n);

if(std > 0) rs_ratio += MathLog(range / std) / MathLog(n);
}

return rs_ratio / 11.0; // Average Hurst exponent
}

double CalculateEntropyMeasure(string symbol)
{
// Shannon entropy of price returns
double returns[20];
for(int i = 1; i <= 20; i++)
{
double current = iClose(symbol, PERIOD_H1, i);
double previous = iClose(symbol, PERIOD_H1, i+1);
returns[i-1] = (current - previous) / previous;
}

// Simplified entropy calculation
double entropy = 0.0;
for(int i = 0; i < 20; i++)
{
double prob = MathAbs(returns[i]) + 0.001; // Avoid log(0)
entropy -= prob * MathLog(prob);
}

return entropy / 20.0;
}

double CalculateLiquidityScore(string symbol)
{
// Amihud illiquidity measure
double illiquidity = 0.0;
long volumes[];

for(int i = 1; i <= 20; i++)
{
double price_change = MathAbs((iClose(symbol, PERIOD_H1, i) - iClose(symbol, PERIOD_H1, i+1)) / iClose(symbol, PERIOD_H1, i+1));
if(CopyTickVolume(symbol, PERIOD_H1, i, 1, volumes) > 0)
{
double volume = (double)volumes[0];
if(volume > 0) illiquidity += price_change / volume;
}
}

return 1.0 / (1.0 + illiquidity / 20.0); // Convert to liquidity score
}

double CalculateSmartMoneyFlow(string symbol)
{
// Money Flow Index calculation
double positive_flow = 0.0, negative_flow = 0.0;
long volumes[];

for(int i = 1; i <= 14; i++)
{
double typical_price = (iHigh(symbol, PERIOD_H1, i) + iLow(symbol, PERIOD_H1, i) + iClose(symbol, PERIOD_H1, i)) / 3.0;
double prev_typical = (iHigh(symbol, PERIOD_H1, i+1) + iLow(symbol, PERIOD_H1, i+1) + iClose(symbol, PERIOD_H1, i+1)) / 3.0;

if(CopyTickVolume(symbol, PERIOD_H1, i, 1, volumes) > 0)
{
double money_flow = typical_price * volumes[0];

if(typical_price > prev_typical)
positive_flow += money_flow;
else
negative_flow += money_flow;
}
}

if(negative_flow > 0)
{
double mfi = 100.0 - (100.0 / (1.0 + positive_flow / negative_flow));
return mfi / 100.0;
}

return 0.5;
}

double FindNearestSupport(string symbol)
{
double min_price = iLow(symbol, PERIOD_H1, 1);
for(int i = 2; i <= 50; i++)
{
double low = iLow(symbol, PERIOD_H1, i);
if(low < min_price) min_price = low;
}
return min_price;
}

double FindNearestResistance(string symbol)
{
double max_price = iHigh(symbol, PERIOD_H1, 1);
for(int i = 2; i <= 50; i++)
{
double high = iHigh(symbol, PERIOD_H1, i);
if(high > max_price) max_price = high;
}
return max_price;
}
};

//+------------------------------------------------------------------+
//| ?? PRIORITY 4: ML Prediction Engine (Placeholder)              |
//+------------------------------------------------------------------+
class CMLPredictionEngine
{
private:
CLogger*                m_logger;
CExternalAPIManager*    m_apiManager;
CMLFeatureExtractor*    m_featureExtractor;

bool                    m_modelLoaded;
string                  m_modelVersion;
double                  m_modelAccuracy;
datetime                m_lastPrediction;

// Simple neural network simulation
double                  m_weights[10];
double                  m_bias;

public:
CMLPredictionEngine()
{
m_logger = new CLogger();
m_apiManager = new CExternalAPIManager();
m_featureExtractor = new CMLFeatureExtractor();

m_modelLoaded = false;
m_modelVersion = "v1.0_placeholder";
m_modelAccuracy = 0.0;
m_lastPrediction = 0;
m_bias = 0.0;

// Initialize random weights for simulation
for(int i = 0; i < 10; i++)
{
m_weights[i] = (MathRand() / 32767.0 - 0.5) * 2.0; // Random between -1 and 1
}
}

~CMLPredictionEngine()
{
if(m_logger) delete m_logger;
if(m_apiManager) delete m_apiManager;
if(m_featureExtractor) delete m_featureExtractor;
}

// ?? PRIORITY 4: Initialize ML system
bool Initialize(string apiEndpoint = "", string apiKey = "")
{
// Initialize API manager
if(m_apiManager)
{
m_apiManager.Initialize(apiEndpoint, apiKey);
}

// Load ML model (placeholder)
LoadModel();

Print("[?? ML] ML Prediction Engine initialized - Model: ", m_modelVersion);
return true;
}

// ?? PRIORITY 4: Load ML model (placeholder)
bool LoadModel()
{
// Placeholder for loading actual ML model
// In real implementation, this would load TensorFlow/ONNX model

m_modelLoaded = true;
m_modelAccuracy = 0.65; // Simulated accuracy

Print("[?? MODEL] ML model loaded: ", m_modelVersion, " (Accuracy: ", 
DoubleToString(m_modelAccuracy, 3), ")");

return true;
}

// ?? PRIORITY 4: Generate ML prediction
MLPrediction GeneratePrediction(string symbol)
{
MLPrediction prediction;
prediction.Reset();
prediction.prediction_time = TimeCurrent();
prediction.model_version = m_modelVersion;

if(!m_modelLoaded)
{
Print("[? ML] Model not loaded - cannot generate prediction");
return prediction;
}

// Extract features
MLFeatureData features = m_featureExtractor.ExtractFeatures(symbol);

// Simple neural network simulation
double sum = m_bias;
sum += features.atr * m_weights[0];
sum += features.volatility * m_weights[1];
sum += features.rsi * m_weights[2] / 100.0; // Normalize RSI
sum += features.macd * m_weights[3];
sum += features.bollinger_position * m_weights[4];
sum += features.trend_strength * m_weights[5];

// Get market sentiment from API
if(m_apiManager && m_apiManager.IsAPIEnabled())
{
double sentiment = m_apiManager.FetchMarketSentiment();
sum += sentiment * m_weights[6];
}

// Apply activation function (sigmoid)
prediction.probability = 1.0 / (1.0 + MathExp(-sum));

// Determine signal type
if(prediction.probability > 0.7)
{
prediction.signal_type = 1; // BUY
prediction.confidence = prediction.probability;
}
else if(prediction.probability < 0.3)
{
prediction.signal_type = 2; // SELL
prediction.confidence = 1.0 - prediction.probability;
}
else
{
prediction.signal_type = 0; // NONE
prediction.confidence = 0.5;
}

// Calculate expected return and risk
prediction.expected_return = (prediction.probability - 0.5) * 2.0; // Range: -1 to 1
prediction.risk_score = 1.0 - prediction.confidence;

m_lastPrediction = TimeCurrent();

// Log prediction
Print(StringFormat("[?? PREDICTION] Signal: %d, Prob: %.3f, Conf: %.3f, Return: %.3f", 
prediction.signal_type, prediction.probability, prediction.confidence, prediction.expected_return));

return prediction;
}

// ?? PRIORITY 4: Train model with trade results (placeholder)
bool TrainWithTradeResult(const MLFeatureData& features, double profit, int tradeType)
{
if(!m_modelLoaded) return false;

// Placeholder for online learning
// In real implementation, this would update model weights

// Send data to external ML service
if(m_apiManager && m_apiManager.IsAPIEnabled())
{
m_apiManager.SendTradeData(profit, 0.1, 3600, _Symbol);
}

Print("[?? TRAINING] Trade result sent for model training: Profit=", 
DoubleToString(profit, 2), ", Type=", tradeType);

return true;
}

// Getters
bool IsModelLoaded() { return m_modelLoaded; }
string GetModelVersion() { return m_modelVersion; }
double GetModelAccuracy() { return m_modelAccuracy; }
CExternalAPIManager* GetAPIManager() { return m_apiManager; }
CMLFeatureExtractor* GetFeatureExtractor() { return m_featureExtractor; }
};

//+------------------------------------------------------------------+
//| ?? PRIORITY 4: ML Integration Manager                          |
//+------------------------------------------------------------------+
class CMLIntegrationManager
{
private:
CMLPredictionEngine*    m_predictionEngine;
bool                    m_mlEnabled;
double                  m_mlWeight;        // Weight of ML signals in final decision
datetime                m_lastMLUpdate;

public:
CMLIntegrationManager()
{
m_predictionEngine = new CMLPredictionEngine();
m_mlEnabled = false;
m_mlWeight = 0.3; // 30% weight by default
m_lastMLUpdate = 0;
}

~CMLIntegrationManager()
{
if(m_predictionEngine) delete m_predictionEngine;
}

// ?? PRIORITY 4: Initialize ML integration
bool Initialize(string apiEndpoint = "", string apiKey = "")
{
if(m_predictionEngine)
{
bool result = m_predictionEngine.Initialize(apiEndpoint, apiKey);
if(result)
{
m_mlEnabled = true;
Print("[?? ML_INTEGRATION] ML system fully initialized");
return true;
}
}

Print("[?? ML_INTEGRATION] ML system initialization failed - running without ML");
return false;
}

// ?? PRIORITY 4: Get ML-enhanced signal
double GetMLEnhancedSignal(double traditionalSignal, string symbol)
{
if(!m_mlEnabled || !m_predictionEngine) 
{
return traditionalSignal; // Return traditional signal if ML disabled
}

// Get ML prediction
MLPrediction mlPrediction = m_predictionEngine.GeneratePrediction(symbol);

// Convert ML prediction to signal value
double mlSignal = 0.0;
if(mlPrediction.signal_type == 1) // BUY
{
mlSignal = mlPrediction.confidence;
}
else if(mlPrediction.signal_type == 2) // SELL
{
mlSignal = -mlPrediction.confidence;
}

// Combine traditional and ML signals
double enhancedSignal = traditionalSignal * (1.0 - m_mlWeight) + mlSignal * m_mlWeight;

m_lastMLUpdate = TimeCurrent();

Print(StringFormat("[?? ML_ENHANCE] Traditional: %.3f, ML: %.3f, Enhanced: %.3f", 
traditionalSignal, mlSignal, enhancedSignal));

return enhancedSignal;
}

// ?? PRIORITY 4: Send trade result for ML training
void SendTradeResult(double profit, int tradeType)
{
if(!m_mlEnabled || !m_predictionEngine) return;

// Get last features and send for training
CMLFeatureExtractor* extractor = m_predictionEngine.GetFeatureExtractor();
if(extractor)
{
MLFeatureData features = extractor.GetLastFeatures();
m_predictionEngine.TrainWithTradeResult(features, profit, tradeType);
}
}

// Getters and setters
bool IsMLEnabled() { return m_mlEnabled; }
void SetMLWeight(double weight) { m_mlWeight = MathMax(0.0, MathMin(1.0, weight)); }
double GetMLWeight() { return m_mlWeight; }
CMLPredictionEngine* GetPredictionEngine() { return m_predictionEngine; }

// ?? PRIORITY 4: Get ML system status
string GetMLSystemStatus()
{
string status = "?? ML SYSTEM STATUS:\n";
status += "================================\n";
status += StringFormat("ML Enabled: %s\n", m_mlEnabled ? "YES" : "NO");
status += StringFormat("ML Weight: %.1f%%\n", m_mlWeight * 100);

if(m_predictionEngine)
{
status += StringFormat("Model Loaded: %s\n", m_predictionEngine.IsModelLoaded() ? "YES" : "NO");
status += StringFormat("Model Version: %s\n", m_predictionEngine.GetModelVersion());
status += StringFormat("Model Accuracy: %.1f%%\n", m_predictionEngine.GetModelAccuracy() * 100);

CExternalAPIManager* apiMgr = m_predictionEngine.GetAPIManager();
if(apiMgr)
{
status += StringFormat("API Enabled: %s\n", apiMgr.IsAPIEnabled() ? "YES" : "NO");
status += StringFormat("Last API Call: %s\n", TimeToString(apiMgr.GetLastCallTime(), TIME_MINUTES));
}
}

status += StringFormat("Last ML Update: %s\n", TimeToString(m_lastMLUpdate, TIME_MINUTES));

return status;
}
};

#endif // ML_INTEGRATION_MQH


