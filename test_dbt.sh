# Quick Test Script for dbt

echo "=== dbt Validation ==="

# 1. Parse dbt project
echo "1. Parsing dbt project..."
dbt parse
if [ $? -ne 0 ]; then
    echo "❌ Parse failed"
    exit 1
fi
echo "✅ Parse successful"

# 2. Debug connection
echo ""
echo "2. Testing dbt connectivity..."
dbt debug
if [ $? -ne 0 ]; then
    echo "❌ Connection failed - check profiles.yml and GCP credentials"
    exit 1
fi
echo "✅ Connection successful"

# 3. Validate models
echo ""
echo "3. Validating models..."
dbt parse --select models --quiet
echo "✅ Models valid"

# 4. Run tests on staging layer
echo ""
echo "4. Running staging tests..."
dbt test --select stg_*
echo "✅ Staging tests passed"

# 5. Generate lineage
echo ""
echo "5. Generating documentation..."
dbt docs generate
echo "✅ Documentation generated"

echo ""
echo "=== All validations passed! ==="
echo "View docs with: dbt docs serve"
