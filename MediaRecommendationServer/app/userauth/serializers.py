from rest_framework import serializers
from . import models


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.User
        fields = ('id', 'username')
        # id = serializers.CharField(source='hash_id', read_only=True)
        # book_user = serializers.PrimaryKeyRelatedField(read_only=True)
        # movie_user = serializers.PrimaryKeyRelatedField(read_only=True)


class BookUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.BookUser
        fields = ('id',)


class MovieUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.MovieUser
        fields = ('id',)
