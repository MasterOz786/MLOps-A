import numpy as np
from flask import Flask, request, jsonify, render_template
import pickle
import os

app = Flask(__name__)

# Load model if it exists, otherwise create a mock model for testing
if os.path.exists('model.pkl'):
    model = pickle.load(open('model.pkl', 'rb'))
else:
    # Create a mock model for testing when model.pkl is not available
    from sklearn.ensemble import ExtraTreesRegressor
    import numpy as np
    # Create a simple mock model that returns a fixed prediction
    model = ExtraTreesRegressor(n_estimators=10)
    # Train with dummy data
    X_dummy = np.random.rand(100, 8)
    y_dummy = np.random.rand(100) * 5  # Ratings between 0-5
    model.fit(X_dummy, y_dummy)

@app.route('/')
def home():
    return render_template('index.html')


@app.route('/predict',methods=['POST'])
def predict():
    '''
    For rendering results on HTML GUI
    '''
    features = [int(x) for x in request.form.values()]
    final_features = [np.array(features)]
    prediction = model.predict(final_features)

    output = round(prediction[0], 1)

    return render_template('index.html', prediction_text='Your Rating is: {}'.format(output))

if __name__ == "__main__":
    app.run(debug=True)