from rest_framework import serializers
from .models import Cliente
from .models import Aduana

class ClienteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cliente
        fields = '__all__'
        
class AduanaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Aduana
        fields = '__all__'