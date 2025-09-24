# Academy Merit Rewards Distribution Contract

An educational-themed token distribution smart contract for the Stacks blockchain. This contract enables academic institutions, learning platforms, and educational DAOs to reward student achievements with merit-based token distributions.

## Overview

The Academy Merit Rewards Contract gamifies learning and achievement through blockchain-based incentives. Deans can manage student enrollment, track academic progress, and distribute merit tokens for educational milestones while maintaining institutional control and security.

## Features

### Dean Administration
- **Student Management**: Register students and manage enrollment status
- **Academic Programs**: Launch semester-based merit distribution programs
- **Honor Roll System**: Recognize exceptional students with special status
- **Curriculum Control**: Approve and manage educational token contracts

### Student Benefits
- **Merit Earning**: Claim academic credits through approved coursework
- **Progress Tracking**: Monitor earned credits and academic standing
- **Achievement Recognition**: Honor roll status and academic milestones

### Institutional Security
- **Access Control**: Dean-only administrative functions
- **Academic Integrity**: Approved curriculum and credit validation
- **Semester Management**: Time-bound academic periods with clear boundaries
- **Emergency Controls**: Fund recovery and program management tools

## Contract Functions

### Dean Functions
```clarity
;; Establish approved curriculum (token contract)
(establish-curriculum (course <merit-token-trait>))

;; Launch new academic program
(launch-academic-program (total-funding uint) (credits-per-milestone uint) (semester-duration uint))

;; Register a student in the program
(register-student (student principal) (max-credits uint))

;; Add student to honor roll
(add-to-honor-roll (student principal))

;; Close enrollment for the semester
(close-enrollment)
```

### Student Functions
```clarity
;; Earn academic credits through coursework
(earn-academic-credits (course <merit-token-trait>))
```

### Read-Only Functions
```clarity
;; Check student's earned credits
(get-student-progress (student principal))

;; Verify student enrollment status
(is-student-enrolled (student principal))

;; Check honor roll membership
(is-on-honor-roll (student principal))

;; Get comprehensive academic program info
(get-academic-overview)
```

## Quick Start

### 1. Deploy the Contract
```bash
clarinet deploy --testnet academy-rewards-contract
```

### 2. Establish Your Curriculum
```clarity
(contract-call? .academy-rewards-contract establish-curriculum .merit-token-contract)
```

### 3. Launch Academic Program
```clarity
(contract-call? .academy-rewards-contract launch-academic-program 
  u1000000    ;; total scholarship funding
  u5000       ;; credits per milestone
  u2000       ;; semester duration in blocks
)
```

### 4. Register Students
```clarity
(contract-call? .academy-rewards-contract register-student 'SP1STUDENT... u25000)
(contract-call? .academy-rewards-contract add-to-honor-roll 'SP1STUDENT...)
```

### 5. Students Earn Credits
Students can now call `earn-academic-credits` to claim their merit tokens for achievements.

## Security Considerations

- **Dean Authority**: Only the dean can manage students and program parameters
- **Accredited Courses**: Only approved curriculum tokens can be distributed
- **Semester Limits**: Distribution periods prevent indefinite claiming
- **Credit Tracking**: Comprehensive monitoring prevents over-allocation
- **Academic Integrity**: Validation ensures legitimate educational usage

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 300 | ERR-UNAUTHORIZED-DEAN | Only the dean can perform this action |
| 301 | ERR-ALREADY-GRADUATED | Student has reached maximum credit allocation |
| 302 | ERR-NOT-ENROLLED | Student is not registered in the program |
| 303 | ERR-INSUFFICIENT-CREDITS | Not enough credits allocated for this claim |
| 304 | ERR-SCHOLARSHIP-DEPLETED | Scholarship fund has been exhausted |
| 305 | ERR-SEMESTER-CLOSED | Academic program enrollment is closed |
| 306 | ERR-NO-CURRICULUM | Course curriculum has not been established |
| 307 | ERR-INVALID-COURSE | Unapproved or invalid course material |
| 308 | ERR-INVALID-CREDIT-VALUE | Credit amount outside valid range |
| 309 | ERR-TERM-EXPIRED | Academic semester has ended |
| 310 | ERR-RESTRICTED-ACCESS | Invalid or restricted address |

## Use Cases

### Educational Institutions
- **Universities**: Reward system for academic achievements and milestones
- **Online Learning**: Token incentives for course completion and excellence
- **Certification Programs**: Merit-based rewards for professional development

### Learning Communities  
- **Educational DAOs**: Decentralized learning with token-based incentives
- **Study Groups**: Collaborative learning rewards and recognition
- **Mentorship Programs**: Token rewards for teaching and learning participation

### Corporate Training
- **Employee Development**: Merit tokens for skill acquisition and training
- **Professional Certification**: Blockchain-verified achievement recognition
- **Learning Platforms**: Gamified education with tangible rewards

## Testing

```bash
# Run comprehensive contract tests
clarinet test

# Validate contract syntax
clarinet check

# Perform security analysis
clarinet analyze
```

## Integration Examples

### Learning Management System
```javascript
// Check student progress
const progress = await contractCall({
  contractAddress: 'ST1...ACADEMY',
  contractName: 'academy-rewards-contract',
  functionName: 'get-student-progress',
  functionArgs: [standardPrincipalCV(studentAddress)]
});
```

### Achievement Dashboard
```javascript
// Verify honor roll status
const honorRoll = await contractCall({
  contractAddress: 'ST1...ACADEMY', 
  contractName: 'academy-rewards-contract',
  functionName: 'is-on-honor-roll',
  functionArgs: [standardPrincipalCV(studentAddress)]
});
```

## Metrics and Analytics

The contract provides comprehensive tracking for:
- **Student Enrollment**: Active learners in the program
- **Credit Distribution**: Total and per-student merit allocation  
- **Academic Progress**: Individual and cohort achievement tracking
- **Honor Roll Statistics**: Recognition and excellence metrics
- **Program Utilization**: Engagement and participation rates
