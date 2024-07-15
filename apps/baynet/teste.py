import pandas as pd
from pgmpy.models import BayesianNetwork
from pgmpy.factors.discrete import TabularCPD
from pgmpy.estimators import MaximumLikelihoodEstimator
from pgmpy.inference import VariableElimination

data = pd.DataFrame({
    'ServiceA_ResponseTime': [0, 1, 1, 0, 0, 1, 1, 0, 0, 1],
    'ServiceB_ErrorRate': [1, 1, 0, 0, 0, 1, 1, 0, 0, 1],
    'ServiceC_CPUUsage': [0, 0, 1, 0, 0, 1, 1, 0, 0, 1],
    'Incident': [1, 1, 0, 0, 0, 1, 1, 0, 0, 1]
})

model = BayesianNetwork([('ServiceA_ResponseTime', 'Incident'), 
                         ('ServiceB_ErrorRate', 'Incident'),
                         ('ServiceC_CPUUsage', 'Incident')])

model.fit(data, estimator=MaximumLikelihoodEstimator)

infer = VariableElimination(model)
result = infer.map_query(variables=['ServiceA_ResponseTime', 'ServiceB_ErrorRate', 'ServiceC_CPUUsage'], evidence={'Incident': 1})
print(result)
