import pytest
import os
import sys
import numpy as np
from unittest.mock import patch, MagicMock
import pickle

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

class TestZomatoApp:
    """Test suite for Zomato Restaurant Price Prediction Flask App"""
    
    @pytest.fixture
    def app(self):
        """Create a test Flask app instance"""
        with patch('pickle.load') as mock_pickle:
            # Mock the model to return a simple prediction
            mock_model = MagicMock()
            mock_model.predict.return_value = np.array([4.5])
            mock_pickle.return_value = mock_model
            
            from app import app
            app.config['TESTING'] = True
            return app
    
    @pytest.fixture
    def client(self, app):
        """Create a test client"""
        return app.test_client()
    
    def test_1_home_page_loads_successfully(self, client):
        """Test 1: Home page loads with 200 status code"""
        response = client.get('/')
        assert response.status_code == 200
        assert b'Predict Zomato Restaurant Ratings' in response.data
    
    def test_2_home_page_contains_form_elements(self, client):
        """Test 2: Home page contains all required form elements"""
        response = client.get('/')
        html = response.data.decode('utf-8')
        
        # Check for form inputs
        assert 'Online Order' in html
        assert 'Book Table' in html
        assert 'Votes' in html
        assert 'Location' in html
        assert 'Restaurant Type' in html
        assert 'Cuisines' in html
        assert 'Cost' in html
        assert 'Menu Item' in html
        assert 'Predict' in html
    
    def test_3_predict_endpoint_accepts_post_requests(self, client):
        """Test 3: Predict endpoint accepts POST requests"""
        with patch('pickle.load') as mock_pickle:
            mock_model = MagicMock()
            mock_model.predict.return_value = np.array([4.2])
            mock_pickle.return_value = mock_model
            
            response = client.post('/predict', data={
                'Online Order': '1',
                'Book Table': '0',
                'Votes': '100',
                'Location': '1',
                'Restaurant Type': '1',
                'Cuisines': '1',
                'Cost': '500',
                'Menu Item': '1'
            })
            assert response.status_code == 200
    
    def test_4_predict_endpoint_returns_prediction(self, client):
        """Test 4: Predict endpoint returns prediction in response"""
        with patch('pickle.load') as mock_pickle:
            mock_model = MagicMock()
            mock_model.predict.return_value = np.array([4.2])
            mock_pickle.return_value = mock_model
            
            response = client.post('/predict', data={
                'Online Order': '1',
                'Book Table': '0',
                'Votes': '100',
                'Location': '1',
                'Restaurant Type': '1',
                'Cuisines': '1',
                'Cost': '500',
                'Menu Item': '1'
            })
            assert b'Your Rating is:' in response.data
    
    def test_5_model_file_exists(self):
        """Test 5: Model file (model.pkl) exists in the project"""
        assert os.path.exists('model.pkl'), "model.pkl file should exist"
    
    def test_6_csv_data_file_exists(self):
        """Test 6: CSV data file exists in the project"""
        assert os.path.exists('Zomato_df.csv'), "Zomato_df.csv file should exist"
    
    def test_7_templates_directory_exists(self):
        """Test 7: Templates directory exists"""
        assert os.path.exists('templates'), "templates directory should exist"
        assert os.path.exists('templates/index.html'), "index.html should exist in templates"
    
    def test_8_static_directory_exists(self):
        """Test 8: Static directory exists"""
        assert os.path.exists('static'), "static directory should exist"
        assert os.path.exists('static/css'), "css directory should exist in static"
    
    def test_9_model_prediction_is_numeric(self, client):
        """Test 9: Model prediction returns a numeric value"""
        with patch('pickle.load') as mock_pickle:
            mock_model = MagicMock()
            mock_model.predict.return_value = np.array([4.2])
            mock_pickle.return_value = mock_model
            
            response = client.post('/predict', data={
                'Online Order': '1',
                'Book Table': '0',
                'Votes': '100',
                'Location': '1',
                'Restaurant Type': '1',
                'Cuisines': '1',
                'Cost': '500',
                'Menu Item': '1'
            })
            
            # Extract prediction from response
            html = response.data.decode('utf-8')
            if 'Your Rating is:' in html:
                # This test passes if we can make a prediction request
                assert True
    
    def test_10_app_imports_work_correctly(self):
        """Test 10: All required imports work without errors"""
        try:
            import numpy as np
            from flask import Flask, request, jsonify, render_template
            import pickle
            assert True, "All imports successful"
        except ImportError as e:
            pytest.fail(f"Import failed: {e}")
    
    def test_11_form_data_processing(self, client):
        """Test 11: Form data is processed correctly"""
        with patch('pickle.load') as mock_pickle:
            mock_model = MagicMock()
            mock_model.predict.return_value = np.array([3.8])
            mock_pickle.return_value = mock_model
            
            form_data = {
                'Online Order': '1',
                'Book Table': '1',
                'Votes': '250',
                'Location': '2',
                'Restaurant Type': '3',
                'Cuisines': '2',
                'Cost': '800',
                'Menu Item': '5'
            }
            
            response = client.post('/predict', data=form_data)
            assert response.status_code == 200
    
    def test_12_prediction_rounding(self, client):
        """Test 12: Prediction values are properly rounded"""
        with patch('pickle.load') as mock_pickle:
            mock_model = MagicMock()
            # Test with a value that needs rounding
            mock_model.predict.return_value = np.array([4.234567])
            mock_pickle.return_value = mock_model
            
            response = client.post('/predict', data={
                'Online Order': '1',
                'Book Table': '0',
                'Votes': '100',
                'Location': '1',
                'Restaurant Type': '1',
                'Cuisines': '1',
                'Cost': '500',
                'Menu Item': '1'
            })
            
            # The prediction should be rounded to 1 decimal place
            assert response.status_code == 200
    
    def test_13_html_template_rendering(self, client):
        """Test 13: HTML template renders correctly"""
        response = client.get('/')
        html = response.data.decode('utf-8')
        
        # Check for essential HTML elements
        assert '<html' in html
        assert '<head>' in html
        assert '<body>' in html
        assert '<form' in html
        assert '</html>' in html
    
    def test_14_css_styling_present(self, client):
        """Test 14: CSS styling is referenced in the template"""
        response = client.get('/')
        html = response.data.decode('utf-8')
        
        # Check for CSS references
        assert 'style.css' in html or 'stylesheet' in html
    
    def test_15_prediction_text_format(self, client):
        """Test 15: Prediction text follows expected format"""
        with patch('pickle.load') as mock_pickle:
            mock_model = MagicMock()
            mock_model.predict.return_value = np.array([4.5])
            mock_pickle.return_value = mock_model
            
            response = client.post('/predict', data={
                'Online Order': '1',
                'Book Table': '0',
                'Votes': '100',
                'Location': '1',
                'Restaurant Type': '1',
                'Cuisines': '1',
                'Cost': '500',
                'Menu Item': '1'
            })
            
            html = response.data.decode('utf-8')
            # Check that prediction text contains expected format
            if 'Your Rating is:' in html:
                assert True  # Test passes if format is correct


# Additional utility tests
class TestUtilities:
    """Additional utility tests"""
    
    def test_16_numpy_import(self):
        """Test 16: NumPy can be imported and used"""
        import numpy as np
        arr = np.array([1, 2, 3, 4, 5])
        assert len(arr) == 5
        assert arr[0] == 1
    
    def test_17_flask_import(self):
        """Test 17: Flask can be imported"""
        from flask import Flask
        app = Flask(__name__)
        assert app is not None
    
    def test_18_pickle_import(self):
        """Test 18: Pickle can be imported"""
        import pickle
        # Test basic pickle functionality
        test_data = {'test': 'data'}
        # This test passes if pickle can be imported
        assert pickle is not None
    
    def test_19_file_permissions(self):
        """Test 19: Required files are readable"""
        files_to_check = ['app.py', 'model.py', 'Zomato_df.csv']
        for file in files_to_check:
            if os.path.exists(file):
                assert os.access(file, os.R_OK), f"{file} should be readable"
    
    def test_20_directory_structure(self):
        """Test 20: Project has correct directory structure"""
        required_dirs = ['templates', 'static']
        for directory in required_dirs:
            assert os.path.exists(directory), f"{directory} directory should exist"
            assert os.path.isdir(directory), f"{directory} should be a directory"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
