
#include "utils_geometry.h"

#include <random>

#include <Eigen/Core>

bool isApprox(const PM::AffineTransform& transformA, const PM::AffineTransform& transformB, const PM::ScalarType epsilon,
              std::string& message)
{
    const PM::StaticCoordVector translationA{ transformA.translation() };
    const PM::StaticCoordVector translationB{ transformB.translation() };
    const PM::StaticCoordVector deltaTranslation{ translationA - translationB };
    // if (deltaTranslation.norm() >= epsilon)
    std::stringstream ss;
    bool areApproxEqual{ true };
    if ((deltaTranslation.array().abs() >= epsilon).any())
    {
        ss << "Translation delta = " << deltaTranslation.transpose() << std::endl;
        ss << "Magnitude of translation delta = " << deltaTranslation.norm() << std::endl;
        areApproxEqual = false;
    }

    const PM::Quaternion rotationQuatA{ transformA.linear() };
    const PM::Quaternion rotationQuatB{ transformB.linear() };
    const PM::Quaternion normalizedRotationQuatA{ rotationQuatA.normalized() };
    const PM::Quaternion normalizedRotationQuatB{ rotationQuatB.normalized() };
    const PM::Quaternion deltaRotation{ normalizedRotationQuatA * normalizedRotationQuatB.inverse() };
    const Eigen::AngleAxis<PM::ScalarType> deltaRotationAngleAxis(deltaRotation);
    if (std::abs(deltaRotationAngleAxis.angle()) >= epsilon)
    {
        ss << "Normalized rotation A =" << normalizedRotationQuatA.coeffs().transpose() << std::endl;
        ss << "Normalized rotation B =" <<  normalizedRotationQuatB.coeffs().transpose() << std::endl;
        ss << "Rotation difference = " << deltaRotation.coeffs().transpose() << std::endl;
        ss << "Angle-Axis angle = " << deltaRotationAngleAxis.angle() << std::endl;
        ss << "Angle-Axis axis = " << deltaRotationAngleAxis.axis() << std::endl;
        areApproxEqual = false;
    }

    ss << "Epsilon = " << epsilon << std::endl;
    message = ss.str();

    return areApproxEqual;
}

PM::ScalarType convertRadiansToDegrees(const PM::ScalarType angleRadians)
{
    return angleRadians * (180.0 / M_PI);
}


PM::ScalarType convertDegreesToRadians(const PM::ScalarType angleDegrees)
{
    return angleDegrees * (M_PI / 180.0);
}

// Creates a quaternion given roll, pitch and yaw (in degrees).
PM::Quaternion buildQuaternionFromRPY(PM::ScalarType roll, PM::ScalarType pitch, PM::ScalarType yaw)
{
    PM::Quaternion q{ Eigen::AngleAxisd(convertDegreesToRadians(roll), Eigen::Vector3d::UnitX())
                      * Eigen::AngleAxisd(convertDegreesToRadians(pitch), Eigen::Vector3d::UnitY())
                      * Eigen::AngleAxisd(convertDegreesToRadians(yaw), Eigen::Vector3d::UnitZ()) };
    q.normalize();

    return q;
}

PM::StaticCoordVector buildRandomVectorFromStdDev(PM::ScalarType translationNoiseStdDev)
{
    return PM::StaticCoordVector::Random() * translationNoiseStdDev;
}

PM::Quaternion buildRandomQuaternionFromStdDev(PM::ScalarType rotationNoiseStdDevInRad)
{
    // Generate rotation angle and axis.
    std::random_device randomDevice;
    std::mt19937 randomNumberGenerator(randomDevice());
    std::normal_distribution<PM::ScalarType> randomDistribution(0, rotationNoiseStdDevInRad);
    const PM::ScalarType rotationAngle{ randomDistribution(randomNumberGenerator) };
    const PM::StaticCoordVector rotationAxis{ PM::StaticCoordVector::Random() };

    // Build quaternion
    PM::Quaternion q{ Eigen::AngleAxis<PM::ScalarType>(rotationAngle, rotationAxis.normalized()) };
    q.normalize();

    return q;
}