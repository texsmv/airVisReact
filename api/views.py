from django.http.response import HttpResponse
from django.shortcuts import render

# Create your views here.


def main(request):
    return HttpResponse('Hello')
    return render(request, 'main.html')
