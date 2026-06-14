const { sendEmergencyAlert } = require('./emailService');

// Risk calculation constants
const RISK_THRESHOLDS = {
  ESCALATION_CONSECUTIVE_HIGH: 3,
  ESCALATION_COOLDOWN_HOURS: 48,
  HIGH_RISK_SCORE: 70,
};

const evaluateAndEscalate = async (
  userId,
  analysisResult,
  userProfile,
  recentAnalyses
) => {
  // Only escalate if AI flagged requiresEscalation and risk score is high
  if (!analysisResult.requiresEscalation) return { escalated: false, reason: 'AI did not flag escalation' };
  if (analysisResult.riskScore < RISK_THRESHOLDS.HIGH_RISK_SCORE) return { escalated: false, reason: 'Risk score below threshold' };

  const emergencyContact = userProfile.emergencyContact;
  if (!emergencyContact?.email || !emergencyContact?.consentGiven) {
    return { escalated: false, reason: 'No emergency contact or no consent' };
  }

  // Check consecutive high-risk days
  const consecutiveHigh = countConsecutiveHighRisk(recentAnalyses || []);
  if (consecutiveHigh < RISK_THRESHOLDS.ESCALATION_CONSECUTIVE_HIGH) {
    return { escalated: false, reason: `Only ${consecutiveHigh} consecutive high risk days (need ${RISK_THRESHOLDS.ESCALATION_CONSECUTIVE_HIGH})` };
  }

  // Check cooldown period
  const lastEscalation = findLastEscalation(recentAnalyses || []);
  if (lastEscalation) {
    const hoursSince = (Date.now() - new Date(lastEscalation).getTime()) / 3600000;
    if (hoursSince < RISK_THRESHOLDS.ESCALATION_COOLDOWN_HOURS) {
      return { escalated: false, reason: `Cooldown active (${Math.round(hoursSince)}h / ${RISK_THRESHOLDS.ESCALATION_COOLDOWN_HOURS}h)` };
    }
  }

  // All conditions met — send alert
  const emailResult = await sendEmergencyAlert({
    contactName: emergencyContact.name,
    contactEmail: emergencyContact.email,
    userName: userProfile.name,
    userFirstName: userProfile.name.split(' ')[0],
    relationship: emergencyContact.relationship || 'trusted contact',
    riskLevel: analysisResult.riskLevel,
  });

  return {
    escalated: emailResult.success,
    emailSentTo: emergencyContact.email,
    consecutiveHighDays: consecutiveHigh,
    error: emailResult.error || null,
  };
};

const countConsecutiveHighRisk = (analyses) => {
  let count = 0;
  for (const analysis of analyses) {
    if (analysis.riskLevel === 'HIGH') count++;
    else break;
  }
  return count;
};

const findLastEscalation = (analyses) => {
  for (const analysis of analyses) {
    if (analysis.escalated) return analysis.analyzedAt;
  }
  return null;
};

module.exports = { evaluateAndEscalate };
