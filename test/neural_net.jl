using Base.Test
using MachineLearning

require("linear_data.jl")

num_features=5
x, y = linear_data(2500, num_features)
x_train, y_train, x_test, y_test = split_train_test(x, y)

# Checking gradients
println("Checking Gradients")
opts = neural_net_options(stop_criteria=StopAfterIteration(5))
classes = sort(unique(y))
classes_map = Dict(classes, [1:length(classes)])
net = initialize_net(opts, classes, num_features)
weights = net_to_weights(net)

actuals = one_hot(y, classes_map)
epsilon = 1e-4
gradients = copy(weights)
for i=1:length(weights)
    w1 = copy(weights)
    w2 = copy(weights)
    w1[i] -= epsilon
    w2[i] += epsilon
    cost_gradient!(net, x, actuals, weights, gradients)
    c1 = cost(net, x, actuals, w1)
    c2 = cost(net, x, actuals, w2)
    err = abs(((c2-c1)/(2*epsilon)-gradients[i])/gradients[i])
    println(i, "\t", err, "\t", (c2-c1)/(2*epsilon), "\t", gradients[i], "\t", weights[i])
    @test err<epsilon
end
#@test err<epsilon

println("Classification Tests")
opts = neural_net_options(learning_rate=10.0, stop_criteria=StopAfterIteration(5))
net = train_soph(x_train, y_train, opts)
for layer=net.layers
    println("Max Weight: ", maximum(layer.weights))
end
yhat = predict(net, x_test)
acc = accuracy(y_test, yhat)
println("Linear Accuracy, Soph: ", acc)
@test acc>0.8

opts = neural_net_options(learning_rate=10.0)
net = train(x_train, y_train, opts)
yhat = predict(net, x_test)
acc = accuracy(y_test, yhat)
println("Linear Accuracy, Valid Stop: ", acc)
@test acc>0.8

opts = neural_net_options(learning_rate=10.0, stop_criteria=StopAfterIteration(40))
net = train(x_train, y_train, opts)
yhat = predict(net, x_test)
acc = accuracy(y_test, yhat)
println("Linear Accuracy, Preset Stop: ", acc)
@test acc>0.8

x = randn(2500, 5)
y = int(map(x->x>0.0, x[:,1]-x[:,2]+3*x[:,3]+x[:,4].*x[:,5]+0.2*randn(2500)))
x_train, y_train, x_test, y_test = split_train_test(x, y)

opts = neural_net_options(learning_rate=10.0)
net = train(x_train, y_train, opts)
yhat = predict(net, x_test)
acc = accuracy(y_test, yhat)
println("Nonlinear Accuracy, 1 Hidden Layer : ", acc)
@test acc>0.80

opts = neural_net_options(hidden_layers=[10;10], learning_rate=10.0)
net = train(x_train, y_train, opts)
yhat = predict(net, x_test)
acc = accuracy(y_test, yhat)
println("Nonlinear Accuracy, 2 Hidden Layers: ", acc)
@test acc>0.80

opts = neural_net_options(hidden_layers=Array(Int, 0), learning_rate=10.0)
net = train(x_train, y_train, opts)
yhat = predict(net, x_test)
acc = accuracy(y_test, yhat)
println("Nonlinear Accuracy, 0 Hidden Layers: ", acc)
@test acc>0.80