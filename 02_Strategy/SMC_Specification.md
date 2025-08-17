# Smart Money Concepts (SMC) - Technical Specification
**Version**: 1.0  
**Date**: 2025-08-15  
**Purpose**: Platform-agnostic SMC signal definitions and scoring methodology

---

## 1. Core Signal Definitions

### 1.1 Break of Structure (BOS)
**Definition**: Price breaks above previous swing high (bullish BOS) or below previous swing low (bearish BOS)
**Parameters**:
- `SMC_MinSwingPips`: 15 (minimum swing size in pips)
- `SMC_BOS_ConfirmPips`: 5 (pips beyond swing to confirm break)
- `SMC_BOS_ATRFilter`: 0.5 (minimum ATR multiplier for valid swing)

### 1.2 Change of Character (CHoCH)
**Definition**: Market structure shift from bullish to bearish or vice versa
**Parameters**:
- `SMC_CHoCH_LookbackBars`: 50 (bars to analyze for structure change)
- `SMC_CHoCH_MinStrength`: 0.6 (minimum strength score 0-1)

### 1.3 Order Block (OB)
**Definition**: Supply/demand zone where institutions placed large orders
**Parameters**:
- `SMC_OB_MaxDistancePips`: 25 (max distance from current price)
- `SMC_OB_MinSizePips`: 8 (minimum order block size)
- `SMC_OB_VolumeThreshold`: 1.5 (volume multiplier vs average)

### 1.4 Liquidity Sweep (LS)
**Definition**: Price temporarily moves beyond key level to trigger stops, then reverses
**Parameters**:
- `SMC_LS_ATRMultiplier`: 1.2 (ATR multiplier for sweep detection)
- `SMC_LS_ReversalPips`: 10 (minimum reversal distance)
- `SMC_LS_TimeframeConfirm`: true (require higher TF confirmation)

### 1.5 Fair Value Gap (FVG)
**Definition**: Imbalance in price action showing inefficiency
**Parameters**:
- `SMC_FVG_MinSizePips`: 12 (minimum gap size)
- `SMC_FVG_MaxFillRatio`: 0.3 (max 30% filled to remain valid)

---

## 2. Scoring Methodology

### 2.1 SMC Score Formula
```
SMC_Score = 0.4 × LS_Score + 0.3 × OB_Score + 0.3 × Structure_Score
```

**Component Scoring (0.0 - 1.0)**:
- **LS_Score**: 1.0 if recent liquidity sweep detected, 0.5 if partial, 0.0 if none
- **OB_Score**: Based on proximity and volume confirmation (1.0 = perfect alignment)
- **Structure_Score**: 0.8 for BOS, 0.6 for CHoCH, 0.0 for no structure change

### 2.2 Pass/Fail Criteria
- **Pass**: SMC_Score ≥ 0.70 AND no conflicting signals
- **Strong**: SMC_Score ≥ 0.80 
- **Weak**: SMC_Score 0.60-0.69 (use with caution)
- **Fail**: SMC_Score < 0.60

---

## 3. API Contract (Platform Agnostic)

### 3.1 Required Inputs
```
SMC_MinSwingPips = 15
SMC_BOS_ConfirmPips = 5  
SMC_OB_MaxDistancePips = 25
SMC_LS_ATRMultiplier = 1.2
SMC_FVG_MinSizePips = 12
SMC_ScoreThreshold = 0.70
```

### 3.2 Required Outputs
```
SMC_Score: double (0.0 - 1.0)
SMC_Direction: enum (BUY/SELL/NEUTRAL)
SMC_Reason: string[] (list of contributing factors)

// Boolean flags
HasBOS: bool
HasCHoCH: bool  
IsAtOrderBlock: bool
HasLiquiditySweep: bool
HasFVG: bool

// Meta information
SMC_Strength: double (0.0 - 1.0)
SMC_Confidence: double (0.0 - 1.0)
SMC_LastUpdate: datetime
```

### 3.3 Validation Test Cases
**Test Case 1**: Bullish BOS + Order Block + Liquidity Sweep
- Expected: SMC_Score ≥ 0.85, Direction = BUY, HasBOS = true, HasLiquiditySweep = true

**Test Case 2**: Bearish CHoCH only
- Expected: SMC_Score ≈ 0.18 (0.3×0.6), Direction = SELL, HasCHoCH = true

**Test Case 3**: Conflicting signals (BOS up + strong bearish OB)
- Expected: SMC_Score < 0.70, Direction = NEUTRAL

---

## 4. Version Control
- **v1.0**: Initial specification with core signals and scoring
- **Future**: Add FVG scoring, multi-timeframe confluence, regime-based thresholds

---

## 5. Implementation Notes
- This specification must be implemented consistently across MQL5 and Pine Script
- Any platform-specific limitations must be documented in respective adapter guides
- Score formulas and thresholds are the single source of truth - do not modify without updating this spec
