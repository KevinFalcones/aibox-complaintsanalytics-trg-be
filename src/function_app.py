import azure.functions as func
import os
import json
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from azure.core.credentials import AzureKeyCredential
from azure.ai.textanalytics import TextAnalyticsClient

app = func.FunctionApp(http_auth_level=func.AuthLevel.FUNCTION)

def get_ai_client():
    kv_url = os.environ["KEY_VAULT_URL"]
    ai_endpoint = os.environ["AI_SERVICE_ENDPOINT"]
    
    # Autentication without passwords using Managed Identity (or Azure CLI in local)
    credential = DefaultAzureCredential()
    secret_client = SecretClient(vault_url=kv_url, credential=credential)
    ai_key = secret_client.get_secret("AiServiceKey").value
    
    return TextAnalyticsClient(endpoint=ai_endpoint, credential=AzureKeyCredential(ai_key))

@app.route(route="analyze_transaction", methods=["POST"])
def analyze_transaction(req: func.HttpRequest) -> func.HttpResponse:
    # Corrección: Usar el logger estándar del framework, no el módulo importado
    print("Starting AI Analytics processing for transaction.") 
    
    try:
        req_body = req.get_json()
        text_to_analyze = req_body.get("customer_comment", "")
        transaction_amount = req_body.get("amount", 0)

        if not text_to_analyze:
            return func.HttpResponse("Missing 'customer_comment' in payload.", status_code=400)

        client = get_ai_client()
        
        # Call to AI Resource: sentiment analysis + entities extract
        sentiment_Result = client.analyze_sentiment(documents=[text_to_analyze])[0]
        entities_Result = client.recognize_entities(documents=[text_to_analyze])[0]

        #  Analytic logic combinated
        risk_flag = "HIGH_RISK" if (sentiment_Result.sentiment == "negative" and transaction_amount > 1000) else "NORMAL"

        response_data = {
            "sentiment": sentiment_Result.sentiment,
            "confidence_scores": {
                "positive": sentiment_Result.confidence_scores.positive,
                "neutral": sentiment_Result.confidence_scores.neutral,
                "negative": sentiment_Result.confidence_scores.negative
            },
            "entities": [{"text": e.text, "category": e.category} for e in entities_Result.entities],
            "analytics_risk_flag": risk_flag
        }

        print(f"Analysis completed successfully. Risk Flag: {risk_flag}")
        return func.HttpResponse(json.dumps(response_data), mimetype="application/json", status_code=200)

    except Exception as e:
        print(f"Critical error in AI pipeline: {str(e)}")
        return func.HttpResponse("Internal Server Error during AI processing.", status_code=500)