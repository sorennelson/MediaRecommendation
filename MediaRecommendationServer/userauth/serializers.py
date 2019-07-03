from rest_framework import serializers
from . import models


class UserSerializer(serializers.ModelSerializer):
    id = serializers.CharField(source='hash_id', read_only=True)
    book_uid = serializers.PrimaryKeyRelatedField(read_only=True)
    movie_uid = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = models.User
        fields = ('id', 'email', 'book_uid', 'movie_uid')
