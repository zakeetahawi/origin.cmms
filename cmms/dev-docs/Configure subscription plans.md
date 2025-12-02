# Atlas CMMS Subscription Plans Configuration
Proceed with the following steps if you have a license to white label. Follow [this](./Run%20SQL%20command.md) if you don't know how to run SQL commands against Atlas database.
## Available Plan Codes

- `FREE`
- `STARTER`
- `PROFESSIONAL`
- `BUSINESS`

## Template

```sql
UPDATE subscription_plan 
SET monthly_cost_per_user = '[MONTHLY_AMOUNT]', 
    yearly_cost_per_user = '[YEARLY_AMOUNT]' 
WHERE code = '[PLAN_CODE]';
```

## Update Statements

### STARTER Plan
```sql
UPDATE subscription_plan
SET monthly_cost_per_user = 100,
    yearly_cost_per_user  = 1000
WHERE code = 'STARTER';
```

### PROFESSIONAL Plan
```sql
UPDATE subscription_plan 
SET monthly_cost_per_user = 150, 
    yearly_cost_per_user = 1500 
WHERE code = 'PROFESSIONAL';
```

### BUSINESS Plan
```sql
UPDATE subscription_plan 
SET monthly_cost_per_user = 200, 
    yearly_cost_per_user = 2000
WHERE code = 'BUSINESS';
```

## Verification Query

```sql
SELECT code, monthly_cost_per_user, yearly_cost_per_user 
FROM subscription_plan 
ORDER BY code;
```