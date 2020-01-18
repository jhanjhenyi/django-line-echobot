from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_POST
from django.http.request import HttpRequest
from django.http.response import HttpResponse


@csrf_exempt
@require_POST
def webhook(request: HttpRequest):
    return HttpResponse("OK")
