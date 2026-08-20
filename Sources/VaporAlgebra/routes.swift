import Vapor
import AlgebraPackage

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    app.get("gcd", ":a", ":b") { req async throws -> String in
        guard let a = req.parameters.get("a", as: Int.self),
              let b = req.parameters.get("b", as: Int.self) else {
            throw Abort(.badRequest, reason: "a y b deben ser enteros")
        }
        return "gcd(\(a), \(b)) = \(intGcd(a, b))"
    }

    app.get("factorize", ":n") { req async throws -> String in
        guard let n = req.parameters.get("n", as: Int.self), n >= 1 else {
            throw Abort(.badRequest, reason: "n debe ser un entero positivo")
        }
        let factors = integerFactorization(n)
            .map { "\($0.0)^\($0.1)" }
            .joined(separator: " · ")
        return "\(n) = \(factors)"
    }

    app.get("factorize") { req async throws in
        try await req.view.render("factorize", ["title": "Factorizar un entero"])
    }

    struct FactorizeForm: Content {
        let n: Int
    }

    app.post("factorize") { req async throws -> View in
        let form = try req.content.decode(FactorizeForm.self)
        guard form.n >= 1 else {
            throw Abort(.badRequest, reason: "n debe ser un entero positivo")
        }
        let result = integerFactorization(form.n)
            .map { "\($0.0)^\($0.1)" }
            .joined(separator: " · ")
        return try await req.view.render("factorize", [
            "title": "Factorizar un entero",
            "n": "\(form.n)",
            "result": result,
        ])
    }

    app.get("plot", "factorize", ":n") { req async throws -> View in
        guard let n = req.parameters.get("n", as: Int.self), n >= 1 else {
            throw Abort(.badRequest, reason: "n debe ser un entero positivo")
        }
        let factors = integerFactorization(n)
        let primesJSON = "[" + factors.map { String($0.0) }.joined(separator: ",") + "]"
        let exponentsJSON = "[" + factors.map { String($0.1) }.joined(separator: ",") + "]"
        return try await req.view.render("plot-factorize", [
            "title": "Factorización de \(n)",
            "n": "\(n)",
            "primes": primesJSON,
            "exponents": exponentsJSON,
        ])
    }

    app.get("plot", "surface") { req async throws -> View in
        let steps = 40
        let range = 3.0
        let stride = 2 * range / Double(steps)
        let axis = (0...steps).map { -range + Double($0) * stride }
        var z: [[Double]] = []
        for y in axis {
            z.append(axis.map { x in x * x - y * y })
        }
        let axisJSON = "[" + axis.map { String($0) }.joined(separator: ",") + "]"
        let zJSON = "[" + z.map { row in
            "[" + row.map { String($0) }.joined(separator: ",") + "]"
        }.joined(separator: ",") + "]"
        return try await req.view.render("plot-surface", [
            "title": "Superficie 3D: z = x² − y²",
            "x": axisJSON,
            "y": axisJSON,
            "z": zJSON,
        ])
    }
}
