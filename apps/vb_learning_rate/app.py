
import os

import dash
import dash_core_components as dcc
import dash_html_components as html
from dash.dependencies import Input, Output

import numpy as np

external_stylesheets = ['https://codepen.io/chriddyp/pen/bWLwgP.css']

# Create layout
app = dash.Dash(__name__, external_stylesheets=external_stylesheets)

# Set server
server = app.server

# Add layout buttons and info
app.layout = html.Div([
    html.Div([
            dcc.Markdown('''
            ### Online Variational Bayes Learning Rate Demo
            
            The following demo showcases how the parameters **tau** and **kappa** affect the learning
            rate of the online VB method. This learning rate is similar to that used in gradient optimization
            methods such as Newton-Raphson. 
            
            To guarantee convergence *kappa* has to be between 0.5-1 and **tau**>0 
            
            [See original paper](https://www.di.ens.fr/~fbach/mdhnips2010.pdf)
            '''),],
            style={'padding-left': '30px','width': '50%', 'display': 'inline-block'}),
    
    html.Div([

        html.Div([
            dcc.Markdown("###### `tau`", style={'padding-left':'20px'}),
            dcc.Slider(
                id='tau-input',
                min=1,
                max=10,
                value=1,
                marks={str(i): str(i) for i in np.arange(1, 10, 1)},
                step=1)],
            style={'flex': '50%','padding': '10px 10px 10px 30px'}),

        html.Div([
            dcc.Markdown("###### `kappa`", style={'padding-left':'20px'}),
            dcc.Slider(
                id='kappa-slider',
                min=0.5,
                max=1,
                value=1,
                marks={str(round(i,3)): str(round(i,3)) for i in np.arange(0.5, 1.01, 0.05)},
                step=0.05),
            
            html.Div(id='slider-output-container', style={'padding-left':'20%'})
        ],
            style={'flex': '50%','padding': '10px'})
        
    ], style={'display': 'flex', 'width':'50%'}),

    dcc.Graph(id='learning-rate', style={'width':'55%'}),

])

# Create callback functions

# Text output under slider
@app.callback(
    Output('slider-output-container', 'children'),
    [Input('tau-input', 'value'),
     Input('kappa-slider', 'value')])
def update_output(tau, kappa):
    return 'Start learning rate: {:2f}'.format((1+tau)**(-kappa))

# Graph
@app.callback(
    Output('learning-rate', 'figure'),
    [Input('tau-input', 'value'),
     Input('kappa-slider', 'value')])
def update_graph(tau, kappa):
    
    lr = lambda t: (t + tau)**(-kappa)
    
    t = np.arange(0.0,60.0, 1.0)
    
    return {
        'data': [dict(
            x=t,
            y=lr(t))
                ],
        'layout': dict(
            xaxis={
                'title': 'Iterations (t)',
                'type': 'linear'
            },
            yaxis={
                'title': 'Learning rate',
                'type': 'linear',
                'range': [0, 1]
            },
            title={
                'text':'Learning rate decay over 60 iterations'},
        )
    }


if __name__ == '__main__':
    app.run_server(debug=True)
