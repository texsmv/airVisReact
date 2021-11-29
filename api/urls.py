from django.urls import path
from .views import AnnualWindowsView, d3Tuto, main, DatasetView

urlpatterns = [
    path('d3', d3Tuto, name='d3tuto'),
    path('api', main, name='main'),
    path('datasets', DatasetView.as_view(), name='datasets'),
    path('windows', AnnualWindowsView.as_view(), name='windows'),
]