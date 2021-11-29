from django.urls import path
from .views import AnnualWindowsView, main, DatasetView

urlpatterns = [
    path('', main),
    path('/datasets', DatasetView.as_view(), name='datasets'),
    path('/windows', AnnualWindowsView.as_view(), name='windows'),
]