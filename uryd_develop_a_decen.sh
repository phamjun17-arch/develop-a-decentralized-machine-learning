#!/bin/bash

# Set up the environment
NODE_COUNT=5
DATA_DIR="./data"
MODEL_DIR="./models"
TEMP_DIR="./temp"

# Function to generate random data
generate_random_data() {
  node_id=$1
  echo "Generating random data for node $node_id..."
  python -c "import numpy as np; np.random.seed($node_id); print(np.random.rand(100, 10))" > $DATA_DIR/node_$node_id.csv
}

# Function to train a machine learning model
train_model() {
  node_id=$1
  echo "Training model on node $node_id..."
  python -c "from sklearn.ensemble import RandomForestClassifier; import pandas as pd; df = pd.read_csv('$DATA_DIR/node_$node_id.csv'); X = df.drop('target', axis=1); y = df['target']; clf = RandomForestClassifier(); clf.fit(X, y)" > $MODEL_DIR/node_$node_id.pkl
}

# Function to combine models
combine_models() {
  echo "Combining models..."
  python -c "import pickle; models = []; for i in $(seq 1 $NODE_COUNT); do models.append(pickle.load(open('$MODEL_DIR/node_$i.pkl', 'rb'))); done; import numpy as np; weights = np.array([1.0/$NODE_COUNT]*$NODE_COUNT); combined_model = weights[0]*models[0]; for i in range(1, $NODE_COUNT); do combined_model += weights[i]*models[i]; done; pickle.dump(combined_model, open('$MODEL_DIR/combined_model.pkl', 'wb'))"
}

# Main script
mkdir -p $DATA_DIR $MODEL_DIR $TEMP_DIR
for i in $(seq 1 $NODE_COUNT); do
  generate_random_data $i &
done
wait
for i in $(seq 1 $NODE_COUNT); do
  train_model $i &
done
wait
combine_models