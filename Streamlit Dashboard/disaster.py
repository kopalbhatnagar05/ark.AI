import json
import numpy as np
from typing import Dict, List, Tuple, Optional, Any

class DisasterCascadePredictor:
    """
    A class for predicting cascading disasters based on a Bayesian network model
    """
    
    def __init__(self, bayesian_network_json_path: str):
        """
        Initialize the predictor with a Bayesian network model
        
        Args:
            bayesian_network_json_path: Path to the JSON file containing the Bayesian network
        """
        # Load the Bayesian network from JSON file
        with open(bayesian_network_json_path, 'r') as f:
            self.bayes_net = json.load(f)
        
        # Validate the loaded network
        self._validate_network()
        
        # Extract disaster types for convenience
        self.disaster_types = self.bayes_net['metadata']['disaster_types']
    
    def _validate_network(self) -> None:
        """Validate that the loaded Bayesian network has the expected structure"""
        required_keys = ['metadata', 'first_order_cpd', 'second_order_cpd']
        for key in required_keys:
            if key not in self.bayes_net:
                raise ValueError(f"Bayesian network missing required key: {key}")
    
    def predict_cascade(self, 
                        initial_disaster: str, 
                        initial_severity: str = "all", 
                        cascade_length: int = 3, 
                        probability_threshold: float = 0.0,
                        top_k: int = 3) -> List[Dict[str, Any]]:
        """
        Predict the most likely cascade of disasters following the initial disaster
        
        Args:
            initial_disaster: The type of the initial disaster (e.g., "earthquake")
            initial_severity: Severity of the initial disaster ("low", "medium", "high", or "all")
            cascade_length: Maximum length of the cascade to predict (including the initial disaster)
            probability_threshold: Minimum probability threshold for including a prediction
            top_k: Number of top cascade paths to return
            
        Returns:
            List of dictionaries representing the most likely cascade paths, each containing:
                - path: List of disaster types in the cascade
                - probabilities: List of individual transition probabilities
                - cumulative_probability: Product of all transition probabilities
        """
        # Validate inputs
        if initial_disaster not in self.disaster_types:
            raise ValueError(f"Unknown disaster type: {initial_disaster}. "
                           f"Must be one of {self.disaster_types}")
        
        if initial_severity not in ["low", "medium", "high", "all"]:
            raise ValueError("Severity must be 'low', 'medium', 'high', or 'all'")
        
        # Start with the initial disaster
        all_paths = [
            {
                "path": [initial_disaster],
                "probabilities": [1.0],  # Initial disaster has 100% probability (it already happened)
                "cumulative_probability": 1.0
            }
        ]
        
        # Generate cascade paths
        for step in range(1, cascade_length):
            new_paths = []
            
            for path_info in all_paths:
                current_path = path_info["path"]
                current_probs = path_info["probabilities"]
                cum_prob = path_info["cumulative_probability"]
                
                # Get the last disaster in the path
                last_disaster = current_path[-1]
                
                # Handle differently based on step number
                if step == 1:
                    # Use first-order CPD for the first transition
                    try:
                        cpd = self.bayes_net["first_order_cpd"][last_disaster][initial_severity]
                    except KeyError:
                        # Fallback to "all" severity if specific severity not found
                        cpd = self.bayes_net["first_order_cpd"][last_disaster]["all"]
                else:
                    # Use second-order CPD for subsequent transitions
                    second_last_disaster = current_path[-2]
                    try:
                        cpd = self.bayes_net["second_order_cpd"][second_last_disaster][last_disaster]
                    except KeyError:
                        # Fallback to first-order CPD if second-order not available
                        cpd = self.bayes_net["first_order_cpd"][last_disaster]["all"]
                
                # Create new paths for each possible next disaster
                for next_disaster, prob in cpd.items():
                    if prob > probability_threshold:
                        new_path = current_path + [next_disaster]
                        new_probs = current_probs + [prob]
                        new_cum_prob = cum_prob * prob
                        
                        new_paths.append({
                            "path": new_path,
                            "probabilities": new_probs,
                            "cumulative_probability": new_cum_prob
                        })
            
            # Sort paths by cumulative probability (descending)
            new_paths.sort(key=lambda x: x["cumulative_probability"], reverse=True)
            
            # Keep only the top_k paths to prevent exponential growth
            all_paths = new_paths[:top_k * 5]  # Keep more than top_k to allow for diversity
        
        # Final sort and return top_k paths
        all_paths.sort(key=lambda x: x["cumulative_probability"], reverse=True)
        return all_paths[:top_k]
    
    def predict_most_likely_next_event(self, 
                                      disaster_sequence: List[str], 
                                      severity_sequence: List[str] = None) -> Tuple[str, float]:
        """
        Predict the single most likely next disaster given a sequence of previous disasters
        
        Args:
            disaster_sequence: List of disasters that have occurred
            severity_sequence: List of severity levels for each disaster (optional)
            
        Returns:
            Tuple of (most_likely_next_disaster, probability)
        """
        if len(disaster_sequence) == 0:
            raise ValueError("Disaster sequence cannot be empty")
        
        # Default severity to "all" if not provided
        if severity_sequence is None:
            severity_sequence = ["all"] * len(disaster_sequence)
        
        # Check if we have only one disaster or multiple
        if len(disaster_sequence) == 1:
            # Use first-order CPD
            cpd = self.bayes_net["first_order_cpd"][disaster_sequence[0]][severity_sequence[0]]
        else:
            # Use second-order CPD for the last two disasters in the sequence
            last_disaster = disaster_sequence[-1]
            second_last_disaster = disaster_sequence[-2]
            
            try:
                cpd = self.bayes_net["second_order_cpd"][second_last_disaster][last_disaster]
            except KeyError:
                # Fallback to first-order if second-order unavailable
                cpd = self.bayes_net["first_order_cpd"][last_disaster][severity_sequence[-1]]
        
        # Find the disaster with highest probability
        most_likely = max(cpd.items(), key=lambda x: x[1])
        return most_likely  # (disaster_type, probability)
    
    def generate_alert_message(self, 
                              initial_disaster: str, 
                              initial_severity: str = "all",
                              location: str = None) -> str:
        """
        Generate a human-readable alert message for potential cascading disasters
        
        Args:
            initial_disaster: Type of disaster that has occurred
            initial_severity: Severity level of the initial disaster
            location: Location where the disaster occurred (optional)
            
        Returns:
            Alert message string
        """
        # Get the top 3 most likely cascade paths
        cascade_paths = self.predict_cascade(
            initial_disaster, 
            initial_severity, 
            cascade_length=3, 
            top_k=3
        )
        
        # Format the location string if provided
        location_str = f" in {location}" if location else ""
        
        # Create the alert message
        message = f"⚠️ CASCADING DISASTER ALERT ⚠️\n\n"
        message += f"A {initial_severity}-severity {initial_disaster} has occurred{location_str}.\n\n"
        message += "Potential cascading disasters within the next 72 hours:\n\n"
        
        for i, path_info in enumerate(cascade_paths, 1):
            path = path_info["path"]
            probs = path_info["probabilities"]
            cum_prob = path_info["cumulative_probability"]
            
            # Skip the first disaster (it already happened)
            next_disasters = path[1:]
            next_probs = probs[1:]
            
            message += f"Scenario {i} ({cum_prob:.1%} probability):\n"
            for j, (disaster, prob) in enumerate(zip(next_disasters, next_probs)):
                message += f"  → {disaster} ({prob:.1%} probability)\n"
            message += "\n"
        
        # Add recommendations
        message += "RECOMMENDED ACTIONS:\n"
        message += "- Monitor conditions within 50km of the initial disaster\n"
        message += "- Prepare emergency resources for potential secondary disasters\n"
        message += "- Evacuate vulnerable areas if necessary\n"
        
        return message


# Example usage
if __name__ == "__main__":
    # Create the predictor
    predictor = DisasterCascadePredictor("cascade-disaster-cpd.json")
    
    # Example 1: Predict cascade after an earthquake
    print("EXAMPLE 1: High-severity earthquake")
    earthquake_cascade = predictor.predict_cascade("earthquake", "high", cascade_length=3, top_k=3)
    for path in earthquake_cascade:
        print(f"Path: {' → '.join(path['path'])}")
        print(f"Probabilities: {[f'{p:.3f}' for p in path['probabilities']]}")
        print(f"Cumulative probability: {path['cumulative_probability']:.3f}")
        print()
    
    # Example 2: Generate an alert message
    print("EXAMPLE 2: Alert message")
    alert = predictor.generate_alert_message("hurricane", "high", "Miami")
    print(alert)
    
    # Example 3: Find the most likely next event
    print("EXAMPLE 3: Most likely next event")
    sequence = ["earthquake", "flood"]
    next_event, probability = predictor.predict_most_likely_next_event(sequence)
    print(f"After {' → '.join(sequence)}, the most likely next event is {next_event} with {probability:.1%} probability")