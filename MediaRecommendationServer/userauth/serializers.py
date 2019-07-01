from rest_framework import serializers
from . import models


class UserSerializer(serializers.ModelSerializer):

    id = serializers.CharField(source='hash_id', read_only=True)

    book_rating_ids = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    book_ratings = serializers.ListField(child=serializers.FloatField())

    movie_rating_ids = serializers.PrimaryKeyRelatedField(many=True, read_only=True)
    movie_ratings = serializers.ListField(child=serializers.FloatField())

    class Meta:
        model = models.User
        fields = ('id', 'email', 'book_rating_ids', 'book_ratings', 'movie_rating_ids', 'movie_ratings')
