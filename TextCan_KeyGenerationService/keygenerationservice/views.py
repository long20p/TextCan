from django.shortcuts import render
from django.http import JsonResponse
from random import randint

characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'

def getkey(request):
    charList = []
    for i in range(0, 8):
        charList.append(characters[randint(0, len(characters) - 1)])
    key = "".join(charList)
    data = {'key': key}
    return JsonResponse(data, content_type='application/json')
