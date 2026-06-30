from rest_framework import serializers
from .models import Cliente
from .models import Aduana
from .models import CategoriaProductos

class ClienteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cliente
        fields = '__all__'
        
class AduanaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Aduana
        fields = '__all__'
        
class CategoriaSerializer(serializers.ModelSerializer):
    class Meta:
        model = CategoriaProductos
        fields = '__all__'