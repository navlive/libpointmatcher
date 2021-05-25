
#include <gtest/gtest.h>

#include <memory>

#include "pointmatcher/DataPointsFilters/utils/octree/Octree.h"

class OctreeTest : public ::testing::Test
{
public:
    using NumericType = float;
    using Octree = Octree_<NumericType, 3>;

    std::unique_ptr<Octree> octree_;

    void SetUp() override { octree_ = std::make_unique<Octree>(); }
};

TEST_F(OctreeTest, Construction) // NOLINT
{
    ASSERT_TRUE(true);
}
