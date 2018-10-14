# Django Line Echo Bot

Line Echo Bot 的實作紀錄

## 開發環境與工具
- Python 3.7
- ngrok
- line-bot-sdk-python
- Heroku

## 開發

### 建立虛擬環境

寫 Python 必備的虛擬環境，可隨意選擇
- [venv](https://docs.python.org/3/library/venv.html)
- [Virtualenv](https://virtualenv.pypa.io/en/stable/)
- [Pipenv](https://pipenv.readthedocs.io/en/latest/)

```
$ pip install Django
$ pip install line-bot-sdk
```

### 建立 Django 專案

```
$ django-admin startproject django_line_bot
$ cd django_line_bot
$ python manage.py startapp echobot
```

### 設定 Webhook URL


為了讓 Line 可以把收到的訊息傳給程式

我們將接收的 Webhook URL 設計成 ```https://{domain name}/echobot/callback/```

#### django_line_bot/urls.py

```python
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('echobot/', include('echobot.urls')),
]
```

#### echobot/urls.py

```python
from django.urls import path

from . import views

urlpatterns = [
    path('callback/', views.callback, name='callback'),
]
```

### 實作 Echo Function

再來就是要在 ```echobot/views.py``` 裡實作 ```callback```

官方已經有提供 Flask 的 Echo-bot 範例
[flask-echo](https://github.com/line/line-bot-sdk-python/tree/master/examples/flask-echo)

```python
from django.conf import settings
from django.http import HttpRequest, HttpResponse, HttpResponseBadRequest
from django.views.decorators.csrf import csrf_exempt

from linebot import LineBotApi, WebhookHandler
from linebot.exceptions import InvalidSignatureError
from linebot.models import MessageEvent, TextMessage, TextSendMessage

line_bot_api = LineBotApi(settings.CHANNEL_ACCESS_TOKEN)
handler = WebhookHandler(settings.CHANNEL_SECRET)


@csrf_exempt
def callback(request: HttpRequest) -> HttpResponse:
    
    if request.method == "POST":
        # get X-Line-Signature header value
        signature = request.META['HTTP_X_LINE_SIGNATURE']

        # get request body as text
        body = request.body.decode('utf-8')

        # handle webhook body
        try:
            handler.handle(body, signature)
        except InvalidSignatureError:
            return HttpResponseBadRequest()

        return HttpResponse()
    else:
        return HttpResponseBadRequest()


@handler.add(MessageEvent, message=TextMessage)
def message_text(event: MessageEvent):
    line_bot_api.reply_message(
        event.reply_token,
        TextSendMessage(text=event.message.text)
    )
```

到這裡，實作的部分就差不多了

## LINE Developers

再來就要到 [Line Developers](https://developers.line.me/en/) 的頁面去申請 Bot

申請流程就不記錄了，總之這是我申請的 Bot

![](/images/bot_card.png)

點進去之後在 **Channel settings** 的頁面中會有一些資訊需要記下來，如果沒有的話可以按 Issue 按紐來產生
- Channel secret
- Channel access token

再來有兩個地方需要設定，由於我們需要將讓 Line 知道要把訊息轉給誰，因此要把 ```Use webhooks``` 設定成 ```Enabled```，```Webhook URL``` 則是設定成前面設計的 Webhook URL，不過目前尚未將程式部屬到網路上所以稍後再設定
- Use webhooks
- Webhook URL
