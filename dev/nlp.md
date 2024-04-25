

single nominal variable - dummy codes or one hot

several nominal variables - more features. no connection between features.  association with y

what about document of words 


bag of words with 1 grams

- binary, count, tf-idf
- no order (context) no relationship (meaning)
- high dimendional
- very sparse representation


Bi, tri- grams

- some order
- even higher dimesions
- no relatioonship still

LIWC

- pennebaker
- meaningful features
- limited

domain specific dictionary approaches

embeddings
- lower dimensional
- dense not sparse
- meaning/context


word2vec (google)

- CBOW
- skipgram

fasttext (facebook ai team)

- n-grams (e.g., 3-6 character representations)
- word vector is sum of its ngrams
- can handle low frequecynor even novel wordsp


glove

elmo
